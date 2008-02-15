module QBFC
  class QuickbooksClosedError < RuntimeError #:nodoc:
  end
  class SetValueMissing < RuntimeError#:nodoc:
  end
  class QBXMLVersionError < RuntimeError#:nodoc:
  end
  class UnknownRequestError < RuntimeError#:nodoc:
  end
  class InvalidRequestError < RuntimeError#:nodoc:
  end
end

# Encapsulates a QBFC session.
# 
#   QBFC::Session.open(:app_name => 'Test Application') do |qb|
#     qb.customers.find(:all).each do |customer|
#       puts customer.full_name
#     end
#   end
# 
#   qb = QBFC::Session.new(:app_name => 'Test Application')
#   qb.customers.find(:all).each do |customer|
#     puts customer.full_name
#   end
#   qb.close
# 
# A QBFC::Session abstracts the ole_methods so that more conventional Ruby method names are used,
# e.g. <tt>full_name</tt> instead of <tt>FullName.GetValue()</tt>.
# 
# This also allows a shortcut for setting up Quickbooks objects:
# 
# - session.customers.find(:all) instead of QBFC::Customer.find(session, :all)
# - session.customer('CustomerFullName') instead of QBFC::Customer.find(session, 'CustomerFullName')

module QBFC
  class Session
    class << self
      
      # Open a QBFC session. Takes options as a hash, and an optional block. Options are:
      # 
      # - +app_name+: Name that the application sends to Quickbooks (used for allowing/denying access)
      #   (defaults to 'Ruby QBFC Application'
      # - +app_id+: Per the Quickbooks SDK (QBFC Language Reference):
      #   'Normally not assigned. Use an empty string for appID.' An empty string is passed by default.
      # - +conn_type+: QBFC_CONST::CtUnknown, CtLocalQBD, CtRemoteQBD, CtLocalQBDLaunchUI, or CtRemoteQBOE.
      #   Default is QBFC_CONST::CtLocalQBD (1)
      # - +filename+: The full path to the Quickbooks file; leave blank to connect to the currently
      #   open company file. Default is an empty string (Quickbooks should be running).
      # - +open_mode+: The desired access mode. It can be one of three values:
      #     - QBFC_CONST::OmSingleUser (specifies single-user mode)
      #     - QBFC_CONST::OmMultiUser (specifies multi-user mode)
      #     - QBFC_CONST::OmDontCare (accept whatever mode is currently in effect, or single-user mode if no other mode is in effect)
      #   Default is QBFC_CONST::OmDontCare
      #   
      # If given a block, it yields the Session object and closes the Session and Connection
      # when the block closes.
      # 
      # Otherwise, it returns the new Session object.
  
      def open(*options, &block)
        qb = new(*options)
        if block_given?
          begin
            yield qb
          ensure
            qb.close
          end
        else
          qb
        end
      end
      
    end
    
    # See Session.open for initialization options.
    def initialize(options = {})
      ole_object = WIN32OLE.new("QBFC6.QBSessionManager")
  
      ole_object.OpenConnection2(options[:app_id].to_s,
                                  (options[:app_name] || "Ruby QBFC Application"),
                                  (options[:conn_type] || QBFC_CONST::CtLocalQBD))
  
      begin
        ole_object.BeginSession(options[:filename].to_s,
                                 (options[:open_mode] || QBFC_CONST::OmDontCare))
      rescue WIN32OLERuntimeError
        ole_object.CloseConnection
        ole_object = nil
        raise QBFC::QuickbooksClosedError, "BeginSession failed: Quickbooks must be open or a valid filename specified."
      end
      
      @ole_object = QBFC::OLEWrapper.new(ole_object)
    end
    
    # Close the session with Quickbooks. If this is ommitted, Quickbooks will not close.
    # Using a block with Session.open ensures the session is closed.
    def close
      @ole_object.EndSession
      @ole_object.CloseConnection
      @ole_object = nil
    end
    
    # Responsible for the conversion of ole_method name to more convential Ruby method names.
    # This specifies the methods for setting up an Entity, such as a Customer, directly, which is
    # not included in OLEWrapper (setting up entities that are children of another entity is).
    # Send other missing methods on to OLE Wrapper
    def method_missing(symbol, *params) #:nodoc:
      if (('a'..'z') === symbol.to_s[0].chr && symbol.to_s[-1].chr != '=')
        camelized_method = symbol.to_s.camelize.to_sym
        single_camelized_method = symbol.to_s.singularize.camelize.to_sym
        if QBFC.const_defined?(camelized_method)
          return QBFC::const_get(camelized_method).find_by_full_name_or_list_id(self, params[0])
        elsif QBFC.const_defined?(single_camelized_method)
          return  QBFC::QBCollection.new(self, single_camelized_method)
        end
      end
      
      # Don't want to pass an OLEWrapper to a WIN32OLE method.
      params = params.collect{ |p| p.respond_to?(:ole_object) ? p.ole_object : p }
      
      @ole_object.qbfc_method_missing(self, symbol, *params)
    end
    
  end
end
