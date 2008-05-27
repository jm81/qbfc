module QBFC
  # A QBFC::Request handles creating and sending a Request, including creating
  # the RequestSet. Most often, RubyQBFC classes create and execute the Request
  # internally, however, the Base.find, for example, accepts a QBFC::Request
  # object as an argument if greater control is needed.
  # 
  # The WIN32OLE Request object is wrapped in OLEWrapper, so Ruby-esque methods
  # can be used.
  # 
  #   req = QBFC::Request.new(qb_session, "CustomerQuery").
  #     or_customer_list_query.customer_list_filter.max_returned = 2
  #   puts req.response
  class Request 
  
    # <tt>session</tt> is a QBFC::Session object (or a Session object not created through Ruby QBFC)
    # <tt>request_type</tt> is the name of the request, not including trailing 'Rq',
    # e.g. 'CustomerQuery', 'CustomerMod'
    def initialize(sess, request_type, country = 'US', major_version = 6, minor_version = 0)
      @sess = sess
      
      begin
        @request_set = sess.CreateMsgSetRequest(country, major_version, minor_version)
      rescue WIN32OLERuntimeError => error
        if error.to_s =~ /error code:8004030A/
          raise QBFC::QBXMLVersionError, "Unsupported qbXML version"
        else
          raise
        end
      end
      
      begin
        @name = request_type
        @request = @request_set.send("Append#{request_type}Rq")
      rescue WIN32OLERuntimeError => error
        if error.to_s =~ /error code:0x80020006/
          raise QBFC::UnknownRequestError, "Unknown request name '#{request_type}'"
        else
          raise
        end
      end
    end
    
    # Submit the requests. This returns the full (not wrapped) response object.
    def submit
      @sess.DoRequests(@request_set)
    end
    
    # Submit the Request and return the response Detail, wrapped in OLEWrapper (unless nil).
    # The response does not include any MsgSetResponse attributes.
    def response
      submit.ResponseList.GetAt(0).Detail
    end
    
    # Is this Query for a Report? The 'conditions' are treated differently
    def for_report?
      @name =~ /Report$/
    end
    
    # Get the OR*Query object of the given Request
    # For example, the ORListQuery
    def query
      query_name = @request.ole_methods.detect{|m| m.to_s =~ /Query\Z/}
      return nil if query_name.nil?
      @request.send(query_name.to_s.to_sym)
    end
    
    # Get the *Filter object of the given Request
    # For example, the ListFilter
    def filter
      q = self.query
      return nil if q.nil?
      filter_name = q.ole_methods.detect{|m| m.to_s =~ /Filter\Z/}
      return nil if filter_name.nil?
      q.send(filter_name.to_s.to_sym)
    end
    
    # Returns where the filter is available for use. That is, that
    # none of the query options other than filter have been used
    def filter_available?
      # -1 = unused, 2 = Filter used
      self.query.ole_object.ortype == -1 ||
        self.query.ole_object.ortype == 2
    end
       
    # Applies options from a Hash. This method is generally used by find methods
    # (see Element.find for details)
    def apply_options(options)      
      if options.kind_of? Hash
        conditions = options.delete(:conditions) || {}
        
        conditions.each do | c_name, c_value |
          c_name = c_name.to_s
          
          case c_name
          when /list\Z/i
            # List filters
            list = query.__send__(c_name.camelize)
            c_value = [c_value] unless c_value.kind_of?(Array)
            c_value.each { |i| list.Add(i) }
          when /range\Z/i
            # Range filters
            c_value = parse_range_value(c_value)
            range_filter = filter_for(c_name)
            range_name = c_name.match(/(.*)_range\Z/i)[1]
            if range_name == 'modified_date'
              # Modified Date Range use the IQBDateTimeType which requires a\
              # boolean 'asDateOnly' value.
              range_filter.__send__("from_#{range_name}=", c_value.first, true) if c_value.first
              range_filter.__send__("to_#{range_name}=", c_value.last, true) if c_value.last
            else
              range_filter.__send__("from_#{range_name}=", c_value.first) if c_value.first
              range_filter.__send__("to_#{range_name}=", c_value.last) if c_value.last
            end
          when /status\Z/i
            # Status filters
            filter.__send__("#{c_name}=", c_value)
          else
            # Reference filters - Only using FullNameList for now
            ref_filter = filter_for(c_name)
            c_value = [c_value] unless c_value.respond_to?(:each)
            c_value.each do | val |
              ref_filter.FullNameList.Add(val)
            end
          end
        end
          
        add_owner_ids(options.delete(:owner_id))
        add_limit(options.delete(:limit))
        add_includes(options.delete(:include))

        options.each do |key, value|
          self.send(key.to_s.camelize).SetValue(value)
        end
      end
    end    
    
    # Add one or more OwnerIDs to the Request. Used in retrieving
    # custom fields (aka private data extensions).
    # Argument should be a single ID or an Array of IDs.
    def add_owner_ids(ids)
      return if ids.nil?
      
      ids = [ids] unless ids.respond_to?(:each)
      ids.each do | id |
        @request.OwnerIDList.Add(id)
      end
    end
    
    # Set MaxReturned to limit the number of records returned.
    def add_limit(limit)
      filter.max_returned = limit if limit
    end
    
    # add_includes accepts an Array of elements to include in the return of the
    # Request. The array may include either or both of elements that are
    # additional to normal returns (such as Line Items, Linked Transactions)
    # or elements that are normally included (to be added to the
    # IncludeRetElementList).
    # 
    # If elements are given that would be added to IncludeRetElementList, this
    # limits the elements returned to *only* those included in the array.
    # 
    # Another option is to give :all as the argument, which will always return
    # as many elements as possible.
    # 
    # add_includes is typically called by #apply_options, typically called
    # from Element.find, as seen in the examples below:
    # 
    #   @sess.checks.find(:all, :include => [:linked_txns]) -> Include linked transactions
    #   @sess.checks.find(:all, :include => [:txn_id]) -> Include +only+ TxnID
    #   @sess.checks.find(:all, :include => :all) ->
    #     Includes all elements, including LinkedTxns and LineItems.
    def add_includes(inc)
      return if inc.nil?
      
      inc = [inc] if (!inc.respond_to?(:each) || inc.kind_of?(String))
      
      if inc.include?(:all)
        ole_methods.each do |m|
          m = m.to_s
          if m =~ /\AInclude/ && m != 'IncludeRetElementList'
            @request.__send__("#{m.underscore}=", true)
          end
        end
        return
      end
      
      inc.each do |item|
        cam_item = item.to_s.camelize.gsub(/Id/, "ID")
        if @request.respond_to_ole?("Include#{cam_item}")
          @request.__send__("include_#{item}=", true)
        else
          @request.IncludeRetElementList.Add(cam_item)
        end
      end
    end
    
    # Parse a value for a range filter. This can be a Range, a one or more
    # element Array or a single value. For a single value or one-element array
    # value#last should return nil. The calling method (#apply_options) will
    # call value#first and value#last to set the from and to values
    # respectively.
    def parse_range_value(value)
      value << nil if value.kind_of?(Array) && value.length == 1
      value = [value, nil] if (value.kind_of?(String) || !value.respond_to?(:first))
      value
    end
    
    # Determine and return the Filter object for the given filter name, dealing
    # with OR's and other "weird" circumstances.
    # NB: This method may well miss some situations. Hopefully, it will become
    # more complete in time.
    def filter_for(name)
      name = name.camelize + "Filter"
      f = nil
      
      # List queries place the modified_date_range directly in the filter
      if name == 'ModifiedDateRangeFilter'
        return filter if filter.respond_to_ole?('FromModifiedDate')
      end
      
      # Report Periods are more or less special circumstance
      if name =~ /^Report[Period|Date]/
        return @request.ORReportPeriod.ReportPeriod
      end
      
      # Try to get the filter directly
      if filter.respond_to_ole?(name)
        f = filter.send(name)
      end

      # Transaction Date Range Filters change name.
      if name == 'TxnDateRangeFilter'
        f = filter.send("TransactionDateRangeFilter").
            send("ORTransactionDateRangeFilter").
            send("TxnDateRange")
      end
      
      # Check if this is within an 'OR'
      if filter.respond_to_ole?("OR#{name}")
        f = filter.send("OR#{name}").send(name)
      elsif filter.respond_to_ole?("OR#{name.gsub(/Range/, '')}")
        f = filter.send("OR#{name.gsub(/Range/, '')}").send(name)
      end
      
      # DateRange OR's
      if filter.respond_to_ole?("ORDateRangeFilter") && name =~ /DateRange/i
        f = filter.send("ORDateRangeFilter").send(name)
      end

      # It might have a nested OR      
      if f && f.respond_to_ole?("OR#{name}")
        f = f.send("OR#{name}")
      end
      
      # Ranges might have another step, with the 'Range' removed.
      if f && f.respond_to_ole?(name.gsub(/Range/, ''))
        f = f.send(name.gsub(/Range/, ''))
      end
      
      return f
    end
    
    private :parse_range_value, :filter_for
    
    # Send missing methods to @ole_object (OLEWrapper)
    def method_missing(symbol, *params) #:nodoc:
      @request.qbfc_method_missing(@sess, symbol, *params)
    end
    
    # Return Array of ole_methods for request WIN32OLE object.
    # This is mostly useful for debugging.
    def ole_methods
      @request.ole_methods
    end

    # Return XML for the request WIN32OLE object.
    # This is mostly useful for debugging.
    def to_xml
      @request_set.ToXMLString
    end

    # Submit Request and return full response as XML.
    # This is mostly useful for debugging.    
    def response_xml
      @sess.DoRequests(@request_set).ToXMLString
    end
    
    # Return actual WIN32OLE object
    def ole_object
      @request.ole_object
    end
  end
end