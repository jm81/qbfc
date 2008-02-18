class QBFC::Base
  class << self

    # Does this class support update operations,
    # i.e. does QBFC support an Modify request for this type?
    def allows_update?
      self.const_defined?(:ALLOWS_UPDATE) ? self::ALLOWS_UPDATE : false
    end
  
    def find(sess, *args)         
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
              filters.delete(:txn_date)
            end

            if filters[:ref_number]
              ref_num_filter = q.send("OR#{self.qb_name}Query").send("#{self.qb_name}Filter").
                               ORRefNumberFilter.RefNumberRangeFilter
              ref_num_filter.FromRefNumber.SetValue( filters[:ref_number][0] ) if filters[:ref_number][0]
              ref_num_filter.ToRefNumber.SetValue( filters[:ref_number][1] ) if filters[:ref_number][1]
              filters.delete(:ref_number)
            end
            
            filters.each do |filter, value|
              q.send("OR#{self.qb_name}Query").
                send("#{self.qb_name}Filter").
                send("#{filter}=", QBFC_CONST::PsNotPaidOnly)
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
      if self.qb_name == "Entity"
        q = create_query(sess)
        q.send("ORListQuery").ListIDList.Add(list_id)
        create_entity(sess, q.response[0], query_options)
      else
        q = create_query(sess, query_options)
        q.send(self.list_query).ListIDList.Add(list_id)
        new(sess, q.response[0])
      end
    end
  
    def find_by_full_name(sess, full_name, query_options = {})
      if self.qb_name == "Entity"
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
      if self.qb_name == "Employee" || self.qb_name == "OtherName"
        "ORListQuery"
      else
        "OR#{self.qb_name}ListQuery"
      end
    end
    
    def create_query(sess, query_options = {})
      q = QBFC::Request.new(sess, "#{self.qb_name}Query")
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
  
    # The QuickBooks name for this Element or Report.
    # It typically matches the last part of class name.
    # Used in determining names of Requests and other
    # OLE methods.
    def qb_name
      self.name.split('::').last
    end
  end
  
  # Create an instance of this Element or Report.
  # - <tt>sess</tt>: An open QBFC::Session object that will recieve all requests
  # - <tt>ole</tt>: An optional QBFC::OLEWrapper object representing
  #   a response to a QueryRq. It is unlikely that this will be used directly.
  def initialize(sess, ole = nil)
    @sess, @ole = sess, ole    
    @ole = QBFC::OLEWrapper.new(@ole) if @ole.kind_of?(WIN32OLE)
    
    if self.class.allows_update? && ole
      mod = QBFC::Request.new(sess, "#{self.class.qb_name}Mod")
          
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
  
  # List the methods of the OLE object
  def ole_methods
    @ole.ole_methods
  end
  
  # Check if the OLE object responds to a given method
  def respond_to_ole?(symbol)
    @ole.respond_to_ole?(symbol)
  end
  
  # Pass missing methods to OLEWrapper#qbfc_method_missing
  # to handle checking if there is a related OLE method to run.
  def method_missing(symbol, *params)
    @ole.qbfc_method_missing(@sess, symbol, *params)
  end
  
  # Name of the QuickBooks Element or Query represented by this class.
  def qb_name
    self.class.qb_name
  end
end

