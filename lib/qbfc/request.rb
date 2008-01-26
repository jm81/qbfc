module QBFC
  class Request
    def initialize(sess, request_type)
      @sess = sess
      @request_set = sess.CreateMsgSetRequest("US", 6, 0)
      @request = @request_set.send("Append#{request_type}Rq")
    end
    
    def response
      detail = @sess.DoRequests(@request_set).ResponseList.GetAt(0).Detail
      detail ? 
        QBFC::OLEWrapper.new(detail) :
        nil
    end
    
    def method_missing(symbol, *params)
      if (('A'..'Z') === symbol.to_s[0].chr)
        @request.send(symbol.to_s.camelize.to_sym, *params)
      else
        raise NoMethodError
      end
    end
    
    def ole_methods
      @request.ole_methods
    end
    
    def to_xml
      @request_set.ToXMLString
    end
    
    def response_xml
      @sess.DoRequests(@request_set).ToXMLString
    end
    
  end
end