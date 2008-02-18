module QBFC
  # Transaction types that do not accept Mod Requests
  TXN_NO_MOD_TYPES = %w{ARRefundCreditCard BillPaymentCreditCard Deposit InventoryAdjustment VehicleMileage VendorCredit }

  # Generate Transaction subclasses
  %w{ARRefundCreditCard Bill BillPaymentCheck BillPaymentCreditCard BuildAssembly Charge Check CreditCardCharge
     CreditCardCredit CreditMemo Deposit Estimate InventoryAdjustment Invoice ItemReceipt JournalEntry PurchaseOrder
     ReceivePayment SalesOrder SalesReceipt SalesTaxPaymentCheck TimeTracking VehicleMileage VendorCredit}.each do | txn_type |
     
    const_set(txn_type, Class.new(Transaction))
    
    unless TXN_NO_MOD_TYPES.include?(txn_type)
      const_get(txn_type).__send__(:include, Modifiable)
    end
  end

  # Types that include Voidable
  %w{ARRefundCreditCard Bill BillPaymentCheck BillPaymentCreditCard Charge Check CreditCardCharge CreditCardCredit
     CreditMemo Deposit InventoryAdjustment Invoice ItemReceipt JournalEntry SalesReceipt VendorCredit}.each do | txn_type |
  
    const_get(txn_type).__send__(:include, Voidable)
  end
end