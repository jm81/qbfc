require File.dirname(__FILE__) + '/voidable'

module QBFC
  class Transaction < Element
    is_base_class
    
    # Alias of TxnID for this record.
    def id
      @ole.txn_id
    end
  end
end