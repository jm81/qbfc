module QBFC
  module Voidable
    def void
      req = QBFC::Request.new(@sess, "TxnVoid")
      req.txn_void_type = QBFC_CONST::const_get("Tvt#{qb_name}")
      req.txn_id = id
      req.submit
      return true
    end
  end
end