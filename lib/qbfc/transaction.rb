require File.dirname(__FILE__) + '/voidable'

module QBFC
  class Transaction < Element
    is_base_class
    
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
  end
end