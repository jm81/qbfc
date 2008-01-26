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
        @request = OLEWrapper.new(@request_set.send("Append#{request_type}Rq"))
      rescue WIN32OLERuntimeError => error
        if error.to_s =~ /error code:0x80020006/
          raise QBFC::UnknownRequestError, "Unknown request name '#{request_type}'"
        else
          raise
        end
      end
    end
    
    # Submit the Request and return the response Detail, wrapped in OLEWrapper (unless nil).
    # The response does not include any MsgSetResponse attributes.
    def response
      detail = @sess.DoRequests(@request_set).ResponseList.GetAt(0).Detail
      detail ? 
        QBFC::OLEWrapper.new(detail) :
        nil
    end
    
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
    
  end
end