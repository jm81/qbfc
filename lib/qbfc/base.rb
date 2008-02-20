class QBFC::Base
  class << self
  
    def find_base(sess, what, *args)
        
        if args[0].kind_of?(QBFC::Request)
          q = args[0]
        else
          q = create_query(sess)
        end
        
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
          
          if options[:owner_id]
            q.OwnerIDList.Add(query_options[:owner_id])
            options.delete(:owner_id)
          end
          
          options.each do |key, value|
            q.send(key.to_s.camelize).SetValue(value)
          end
        end
        
        return q

    end
    
    def list_query
      if qb_name == "Employee" || qb_name == "OtherName"
        "ORListQuery"
      else
        "OR#{self.qb_name}ListQuery"
      end
    end
    
    def create_query(sess)
      QBFC::Request.new(sess, "#{qb_name}Query")
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

