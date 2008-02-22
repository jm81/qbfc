class QBFC::Base
  class << self
  
    def apply_options(sess, q, options)
        
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
          
          q.add_owner_ids(options.delete(:owner_id))

          options.each do |key, value|
            q.send(key.to_s.camelize).SetValue(value)
          end
        end
        
        return q

    end
    
    # Element::find and Info::get receive optional arguments which can include
    # a Request object and/or an options Hash. <tt>parse_find_args</tt>
    # gets these arguments into a set that is easier to deal with.
    def parse_find_args(*args)
      request = args[0].kind_of?(QBFC::Request) ? args[0] : nil
      options = args[-1].kind_of?(Hash) ? args[-1] : {}
      
      # base classes will need to pass a subset of options to
      # the ChildClass.find . Also, the actually options to the
      # BaseClass.find Request cannot include owner_id.
      if is_base_class?
        base_options = options.dup 
        base_options.delete(:conditions)
        options.delete(:owner_id)
      else
        base_options = nil
      end
      
      return request, options, base_options
    end
    
    private :parse_find_args
    
    # A convenience method for creating and returning
    # a Query Request for this class.
    def create_query(sess)
      QBFC::Request.new(sess, "#{qb_name}Query")
    end
    
    private :create_query
  
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

