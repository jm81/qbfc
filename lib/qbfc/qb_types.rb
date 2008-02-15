ELEMENTS_ADD_QUERY = %w{ARRefundCreditCard BillPaymentCreditCard BillingRate CustomerMsg CustomerType DateDrivenTerms 
                        Deposit InventoryAdjustment JobType PaymentMethod PayrollItemWage SalesTaxCode ShipMethod StandardTerms 
                        ToDo VehicleMileage VendorCredit VendorType} # Remove 'Class'
 
ELEMENTS_ADD_MOD_QUERY = %w{Account Bill BillPaymentCheck BuildAssembly Charge Check CreditCardCharge CreditCardCredit
                            CreditMemo Customer DataExtDef Employee Estimate Invoice ItemDiscount ItemFixedAsset ItemGroup
                            ItemInventory ItemInventoryAssembly ItemNonInventory ItemOtherCharge ItemPayment ItemReceipt
                            ItemSalesTax ItemSalesTaxGroup ItemService ItemSubtotal JournalEntry OtherName PriceLevel
                            PurchaseOrder ReceivePayment SalesOrder SalesReceipt SalesRep TimeTracking Vehicle Vendor}
 
ELEMENTS_QUERY = %w{AgingReport BillToPay BudgetSummaryReport Company CompanyActivity CustomDetailReport CustomSummaryReport
                    DataEventRecoveryInfo Entity GeneralDetailReport GeneralSummaryReport Host ItemAssembliesCanBuild Item
                    JobReport ListDeleted PayrollDetailReport PayrollItemNonWage PayrollSummaryReport Preferences
                    ReceivePaymentToDeposit SalesTaxPaymentCheck Template Terms TimeReport Transaction TxnDeleted}

ELEMENTS_ADD = %w{SpecialAccount SpecialItem}

ELEMENTS_MOD = %w{ClearStatus}

ELEMENTS_ADD_MOD = %w{DataExt ListDisplay TxnDisplay}

# TxnDel - Types that can be deleted by a TxnDelRq
TXN_DEL_TYPES = %w{ARRefundCreditCard Bill BillPaymentCheck BillPaymentCreditCard BuildAssembly Charge Check CreditCardCharge
                   CreditCardCredit CreditMemo Deposit Estimate InventoryAdjustment Invoice ItemReceipt JournalEntry PurchaseOrder
                   ReceivePayment SalesOrder SalesReceipt SalesTaxPaymentCheck TimeTracking VehicleMileage VendorCredit}

# TxnVoid - Types that can be voided by a TxnVoidRq
TXN_VOID_TYPES = %w{ARRefundCreditCard Bill BillPaymentCheck BillPaymentCreditCard Charge Check CreditCardCharge CreditCardCredit
                    CreditMemo Deposit InventoryAdjustment Invoice ItemReceipt JournalEntry SalesReceipt VendorCredit}

# ListDel - Types that can be deleted by a ListDelRq
LIST_DEL_TYPES = %w{Account BillingRate Class Customer CustomerMsg CustomerType DateDrivenTerms Employee ItemDiscount
                    ItemFixedAsset ItemGroup ItemInventory ItemInventoryAssembly ItemNonInventory ItemOtherCharge
                    ItemPayment ItemSalesTax ItemSalesTaxGroup ItemService ItemSubtotal JobType OtherName PaymentMethod
                    PayrollItemNonWage PayrollItemWage PriceLevel SalesRep SalesTaxCode ShipMethod StandardTerms ToDo
                    Vehicle Vendor VendorType}

# Types that have their own DelRq
ELEMENT_DEL_TYPES = %w{DataEventRecoveryInfo DataExt DataExtDef}

module QBFC
  # Create QBElement classes
  (ELEMENTS_ADD_QUERY + ELEMENTS_ADD_MOD_QUERY + ELEMENTS_QUERY + ELEMENTS_ADD + ELEMENTS_MOD + ELEMENTS_ADD_MOD).uniq.each do | qb_element_name |
    const_set(qb_element_name, Class.new(Base))
  end
  
  # Set up types with Query
  (ELEMENTS_ADD_QUERY + ELEMENTS_ADD_MOD_QUERY + ELEMENTS_QUERY).uniq.each do | qb_element_name |
    const_get(qb_element_name).class_eval do
      const_set(:ALLOWS_READ, true)
    end
  end
  
  # Set up types with Mod
  (ELEMENTS_MOD + ELEMENTS_ADD_MOD_QUERY + ELEMENTS_ADD_MOD).uniq.each do | qb_element_name |
    const_get(qb_element_name).class_eval do
      const_set(:ALLOWS_UPDATE, true)
    end
  end
end