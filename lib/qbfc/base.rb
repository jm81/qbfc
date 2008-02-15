class QBFC::Base
  class << self

    # Does this class support read operations,
    # i.e. does QBFC support a Query request for this type?
    # Notably, this means that the full finder is enabled
    # (see +find+ for details).
    def allows_read?
      self.const_defined?(:ALLOWS_READ) ? self::ALLOWS_READ : false
    end

    # Does this class support create operations,
    # i.e. does QBFC support an Add request for this type?
    def allows_create?
      self.const_defined?(:ALLOWS_CREATE) ? self::ALLOWS_CREATE : false
    end

    # Does this class support update operations,
    # i.e. does QBFC support an Modify request for this type?
    def allows_update?
      self.const_defined?(:ALLOWS_UPDATE) ? self::ALLOWS_UPDATE : false
    end

    # Does this class support delete operations,
    # i.e. is this class supported by QBFC's TxnDel or ListDel or
    # have its own Del request.
    def allows_delete?
      self.const_defined?(:ALLOWS_DELETE) ? self::ALLOWS_DELETE : false
    end
    
    # Does this class support void operations,
    # i.e. is this class supported by QBFC's TxnVoid request
    def allows_void?
      self.const_defined?(:ALLOWS_VOID) ? self::ALLOWS_VOID : false
    end
  
    def find(sess, *args)
      if !allows_read?
        if (hsh = args.last) && hsh.kind_of?(Hash) && 
            (hsh[:list_id] || hsh[:full_name] || hsh[:name])
          return new(sess, hsh)
        else
          raise RuntimeError, "Find for non-readable class '#{class_name}' requires a name or list_id"
        end
      end
          
      if args[0].kind_of?(String) # Single FullName or ListID
        find_by_full_name_or_list_id(sess, args[0])
      else
      
        q = create_query(sess)
        
        options = args[-1]
        if options.kind_of? Hash
          filters = options[:conditions]
          if filters
            if filters[:txn_date]
              txn_date_filter = q.ORTxnQuery.TxnFilter.ORDateRangeFilter.TxnDateRangeFilter.ORTxnDateRangeFilter.TxnDateFilter
              txn_date_filter.FromTxnDate.SetValue( filters[:txn_date][0] ) if filters[:txn_date][0]
              txn_date_filter.ToTxnDate.SetValue( filters[:txn_date][1] ) if filters[:txn_date][1]
            end
            options.delete(:conditions)
          end
          options.each do |key, value|
            q.send(key.to_s.camelize).SetValue(value)
          end
        elsif options.kind_of? QBFC::Request
          q = options
        end
        
        list = q.response
        
        if list.nil?
          (args[0] == :all || args.empty?) ? [] : nil
        elsif args[0] == :all || args.empty?
          ary = []
          0.upto(list.Count - 1) do |i|
            ary << new(sess, list.GetAt(i))
          end
          ary
        else
          if list.ole_methods.detect{|m| m.to_s == "GetAt"}
            return new(sess, list.GetAt(0))
          else
            return new(sess, list)
          end
        end
      end
    end
    
    def find_by_full_name_or_list_id(sess, id, query_options = {})
      id =~ /\d+-\d+/ ?
        find_by_list_id(sess, id, query_options) :
        find_by_full_name(sess, id, query_options)
    end
    
    def find_by_list_id(sess, list_id, query_options = {})
      if self.class_name == "Entity"
        q = create_query(sess)
        q.send("ORListQuery").ListIDList.Add(list_id)
        create_entity(sess, q.response[0], query_options)
      else
        q = create_query(sess, query_options)
        q.send(self.list_query).ListIDList.Add(list_id)
        new(sess, q.response[0])
      end
    end
  
    def find_by_full_name(sess, full_name, options = {})
      if self.class_name == "Entity"
        q = create_query(sess)
        q.send("ORListQuery").FullNameList.Add(full_name)
        create_entity(sess, q.response[0], query_options)
      else
        q = create_query(sess, query_options)
        q.send(self.list_query).FullNameList.Add(full_name)
        new(sess, q.response[0])
      end
    end
    
    alias_method :find_by_name, :find_by_full_name
    
    def list_query
      if self.class_name == "Employee" || self.class_name == "OtherName"
        "ORListQuery"
      else
        "OR#{self.class_name}ListQuery"
      end
    end
    
    def create_query(sess, query_options = {})
      q = QBFC::Request.new(sess, "#{self.class_name}Query")
      if query_options[:owner_id]
        q.OwnerIDList.Add(query_options[:owner_id]) 
      end
      q
    end
    
    def create_entity(sess, r, query_options = {})
      ret = get_entity_ret(sess, r)
      if query_options.empty?
        ret
      else
        ret.class.find_by_list_id(sess, ret.ListID.GetValue(), query_options)
      end
    end
    
    def get_entity_ret(sess, r)
      return QBFC::Vendor.new(sess, r.VendorRet) if r.VendorRet
      return QBFC::Employee.new(sess, r.EmployeeRet) if r.EmployeeRet
      return QBFC::OtherName.new(sess, r.OtherNameRet) if r.OtherNameRet
      return QBFC::Customer.new(sess, r.CustomerRet) if r.CustomerRet
    end
    
    private :create_query, :create_entity, :get_entity_ret
  
    def class_name
      self.name.split('::').last
    end
  end
  
  def initialize(sess, ole = nil)
    @sess = sess
    
    if ole.kind_of?(QBFC::OLEWrapper)
      @ole = ole
    elsif ole.kind_of?(WIN32OLE)
      @ole = QBFC::OLEWrapper.new(ole)
    else
      # TODO: Can I create a 'generic'?
    end
    
    if self.class.allows_update?
      mod = QBFC::Request.new(sess, "#{self.class.class_name}Mod")
          
      if respond_to_ole?(:ListID)
        mod.list_id = @ole.list_id
      elsif respond_to_ole?(:TxnID)
        mod.txn_id = @ole.txn_id
      end

      mod.edit_sequence = @ole.edit_sequence
      
      @setter = mod
      @ole.setter = mod.ole_object
    end
    
  end
  
  # If an entity has a Name field but not a FullName field,
  # use Name (which, by implication, is the FullName)
  def full_name
    @ole.ole_methods.detect{|m| m.to_s == "FullName"} ?
      @ole.FullName.GetValue :
      @ole.Name.GetValue
  end
  
  # Get ListID or TxnID.
  def id
    if respond_to_ole?(:ListID)
      @ole.list_id
    elsif respond_to_ole?(:TxnID)
      @ole.txn_id
    else
      nil
    end
  end
  
  # Access custom fields
  def custom(field_name, owner_id = 0)
    return nil unless @ole.DataExtRetList
    @ole.data_ext.each do |field|
      return field.data_ext_value if field.data_ext_name == field_name
    end
    return nil
  end
  
  def save
    @setter.submit
  end
  
  def ole_methods
    @ole.ole_methods
  end
  
  def respond_to_ole?(symbol)
    @ole.respond_to_ole?(symbol)
  end
  
  def method_missing(symbol, *params)
    @ole.qbfc_method_missing(@sess, symbol, *params)
  end
end

