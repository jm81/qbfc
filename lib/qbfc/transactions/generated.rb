module QBFC

  # Generated Transaction types
  TXN_TYPES = %w{ARRefundCreditCard Bill BillPaymentCheck BillPaymentCreditCard
      BuildAssembly Charge Check CreditCardCharge CreditCardCredit CreditMemo
      Deposit Estimate InventoryAdjustment Invoice ItemReceipt JournalEntry
      PurchaseOrder ReceivePayment SalesOrder SalesReceipt SalesTaxPaymentCheck 
      TimeTracking VehicleMileage VendorCredit}

  # Generated Transaction types that support TxnVoid Request
  TXN_VOIDABLE_TYPES = %w{ARRefundCreditCard Bill BillPaymentCheck
      BillPaymentCreditCard Charge Check CreditCardCharge CreditCardCredit
      CreditMemo Deposit InventoryAdjustment Invoice ItemReceipt JournalEntry
      SalesReceipt VendorCredit}
  
  # Generated Transaction types that don't support Mod Requests
  TXN_NO_MOD_TYPES = %w{ARRefundCreditCard BillPaymentCreditCard Deposit
    InventoryAdjustment VehicleMileage VendorCredit }
  
  # Generate Transaction subclasses
  generate(TXN_TYPES, Transaction,
    { Modifiable => (TXN_TYPES - TXN_NO_MOD_TYPES),
      Voidable => TXN_VOIDABLE_TYPES })
  
end