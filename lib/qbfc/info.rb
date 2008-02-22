module QBFC
  # Info objects are those which have only one instance within Quickbooks,
  # which are: Company, CompanyActivity, Host and Preferences.
  # 
  # Access through QBFC for these objects is read-only.
  # 
  # QBFC::Info can be accessed via session::company, for example, or
  # through QBFC::Company::get(session).
  class Info < Base
    class << self
      
      # Get the Info object for the given session.
      # session.[qb_name] aliases this functionality.
      # For example QBFC::Company.get(session) and
      # session.company are equivalent.
      # 
      # It accepts the follow options as a hash:
      # - <tt>:owner_id</tt>: One or more OwnerIDs, used in accessing
      #   custom fields (aka private data extensions).
      def get(sess, *args)
        # Setup q, options and base_options arguments
        q, options, base_options = parse_find_args(*args)
        q ||= create_query(sess)
        q.apply_options(options)
        
        new(sess, q.response)
      end
      
      # This is a convenience alias for +get+.
      # It exists solely so that I don't have to modify
      # Session#method_missing.
      def find(sess, what, *args) #:nodoc:
        get(sess, *args)
      end
    end
  end
end

# Require subclass files
Dir[File.dirname(__FILE__) + '/infos/*.rb'].each do |file|
  require file
end
