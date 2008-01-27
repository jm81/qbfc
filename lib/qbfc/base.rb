class QBFC::Base
  class << self
    def allows_read?
      self.const_defined?(:ALLOWS_READ) ? self::ALLOWS_READ : false
    end

    def allows_create?
      self.const_defined?(:ALLOWS_CREATE) ? self::ALLOWS_CREATE : false
    end

    def allows_update?
      self.const_defined?(:ALLOWS_UPDATE) ? self::ALLOWS_UPDATE : false
    end

    def allows_delete?
      self.const_defined?(:ALLOWS_DELETE) ? self::ALLOWS_DELETE : false
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
    
    def find_by_full_name_or_list_id(sess, id)
      id =~ /\d+-\d+/ ?
        find_by_list_id(sess, id) :
        find_by_full_name(sess, id)
    end
    
    def find_by_list_id(sess, list_id)
      q = create_query(sess)
      if self.class_name == "Entity"
        q.send("ORListQuery").ListIDList.Add(list_id)
        create_entity(sess, q.response[0])
      else
        q.send("OR#{self.class_name}ListQuery").ListIDList.Add(list_id)
        new(sess, q.response[0])
      end
    end
  
    def find_by_full_name(sess, full_name)
      q = create_query(sess)
      if self.class_name == "Entity"
        q.send("ORListQuery").FullNameList.Add(full_name)
        create_entity(sess, q.response[0])
      else
        q.send("OR#{self.class_name}ListQuery").FullNameList.Add(full_name)
        new(sess, q.response[0])
      end
    end
    
    alias_method :find_by_name, :find_by_full_name
    
    def create_query(sess)
      QBFC::Request.new(sess, "#{self.class_name}Query")
    end
    
    def create_entity(sess, r)
      return QBFC::Vendor.new(sess, r.VendorRet) if r.VendorRet
      return QBFC::Employee.new(sess, r.EmployeeRet) if r.EmployeeRet
      return QBFC::OtherName.new(sess, r.OtherNameRet) if r.OtherNameRet
      return QBFC::Customer.new(sess, r.CustomerRet) if r.CustomerRet
    end
    
    private :create_query, :create_entity
  
    def class_name
      self.name.split('::').last
    end
  end
  
  def initialize(sess, ole_object = nil)
    @sess = sess
    
    if ole_object.kind_of?(QBFC::OLEWrapper)
      @ole_object = ole_object
    elsif ole_object.kind_of?(WIN32OLE)
      @ole_object = QBFC::OLEWrapper.new(ole_object)
    else
      # TODO: Can I create a 'generic'?
    end
    
  end
  
  # If an entity has a Name field but not a FullName field,
  # use Name (which, by implication, is the FullName)
  def full_name
    @ole_object.ole_methods.detect{|m| m.to_s == "FullName"} ?
      @ole_object.FullName.GetValue :
      @ole_object.Name.GetValue
  end
  
  def ole_methods
    @ole_object.ole_methods
  end
  
  def method_missing(symbol, *params)
    @ole_object.qbfc_method_missing(@sess, symbol, *params)
  end
end

