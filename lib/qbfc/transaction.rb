require File.dirname(__FILE__) + '/voidable'

module QBFC
  class Transaction < Element
    is_base_class
    
    class << self
      
      # Find by Reference Number of the Transaction record.
      # +options+ are the same as those for in +find+.
      def find_by_ref(sess, ref, options = {})
        q = create_query(sess)
        q.query.RefNumberList.Add(ref)
        find(sess, :first, q, options)
      end
      
      # Find by TxnID of List record.
      # +options+ are the same as those for in +find+.      
      def find_by_id(sess, id, options = {})
        q = create_query(sess)
        q.query.TxnIDList.Add(id)
        find(sess, :first, q, options)
      end
      
      # Find by either ref or id. Tries id first, then ref.
      def find_by_ref_or_id(*args)
        find_by_id(*args) || find_by_ref(*args)
      end
      
      alias_method :find_by_unique_id, :find_by_ref_or_id
      
    end
    
    # Alias of TxnID for this record.
    def id
      @ole.txn_id
    end
    
    # Delete this Transaction
    def delete
      req = QBFC::Request.new(@sess, "TxnDel")
      req.txn_del_type = QBFC_CONST::const_get("Tdt#{qb_name}")
      req.txn_id = id
      req.submit
      return true
    end
    
    # Change cleared status of transaction
    # status can be one of:
    # - QBFC::CsCleared (or true)
    # - QBFC::CsNotCleared (or false)
    # - QBFC::CsPending
    def cleared_status=(status)
      req = QBFC::Request.new(@sess, "ClearedStatusMod")
      req.txn_id = id
      status = QBFC_CONST::CsCleared if status === true
      status = QBFC_CONST::CsNotCleared if status === false
      req.cleared_status = status
      req.submit
      return status
    end
    
    # Display the Transaction add (for new records) or edit dialog box
    def display
      if new_record?
        req = QBFC::Request.new(@sess, "TxnDisplayAdd")
        req.txn_display_add_type = QBFC_CONST::const_get("Tdat#{qb_name}")
      else
        req = QBFC::Request.new(@sess, "TxnDisplayMod")
        req.txn_display_mod_type = QBFC_CONST::const_get("Tdmt#{qb_name}")
        req.txn_id = id
      end
      req.submit
      return true
    end
  end
end

# Require subclass files
Dir[File.dirname(__FILE__) + '/transactions/*.rb'].each do |file|
  require file
end
