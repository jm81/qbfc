# This file sets up the classes for QuickBooks entities, transactions and reports.

# TODO: Remember ClearStatusMod for transactions
# TODO: Remember TxnDisplayAdd and TxnDisplayMod
QBFC_TXN_TYPES  = %w{ARRefundCreditCard Bill BillPaymentCheck BillPaymentCreditCard BuildAssembly Charge Check CreditCardCharge
                     CreditCardCredit CreditMemo Deposit Estimate InventoryAdjustment Invoice ItemReceipt JournalEntry PurchaseOrder
                     ReceivePayment SalesOrder SalesReceipt SalesTaxPaymentCheck TimeTracking VehicleMileage VendorCredit}
                     
# TxnVoid - Types that can be voided by a TxnVoidRq
QBFC_VOID_TYPES = %w{ARRefundCreditCard Bill BillPaymentCheck BillPaymentCreditCard Charge Check CreditCardCharge CreditCardCredit
                     CreditMemo Deposit InventoryAdjustment Invoice ItemReceipt JournalEntry SalesReceipt VendorCredit}

# List types that will inherit directly from QBFC::List
# TODO: Remember ListDisplayAdd and ListDisplayMod
QBFC_LIST_TYPES = %w{Account BillingRate QBClass CustomerMsg CustomerType JobType  PaymentMethod
                     PayrollItemNonWage PayrollItemWage PriceLevel SalesRep SalesTaxCode ShipMethod ToDo
                     Vehicle VendorType}

# Inherit from List                     
QBFC_ENTITY_TYPES = %w{Customer Employee OtherName Vendor}

# Inherit from List
QBFC_ITEM_TYPES = %w{ItemService ItemNonInventory ItemOtherCharge ItemInventory ItemInventoryAssembly ItemFixedAsset
                     ItemSubtotal ItemDiscount ItemPayment ItemSalesTax ItemSalesTaxGroup ItemGroup}

# Inherit from List
QBFC_TERMS_TYPES = %w{DateDrivenTerms StandardTerms}
             
# List and Transaction types that do not accept Mod Requests       
QBFC_NO_MOD_TYPES = %w{ARRefundCreditCard BillPaymentCreditCard BillingRate CustomerMsg CustomerType DateDrivenTerms 
                       Deposit InventoryAdjustment JobType PaymentMethod PayrollItemWage SalesTaxCode ShipMethod StandardTerms 
                       ToDo VehicleMileage VendorCredit VendorType QBClass}

# Types that allow Query and Delete only
QBFC_DELETE_ONLY = %w{PayrollItemNonWage DataEventRecoveryInfo}

# Report types support Query requests only and return an itemized list of some sort;
# sometimes, this includes meta-information about the report (e.g. header)
QBFC_REPORT_TYPES = %w{AgingReport BillToPay BudgetSummaryReport CustomDetailReport CustomSummaryReport
                      GeneralDetailReport GeneralSummaryReport 
                    JobReport ListDeleted PayrollDetailReport PayrollSummaryReport 
                    ReceivePaymentToDeposit SalesTaxPaymentCheck Template TimeReport TxnDeleted}

# Info Types support Query requests only and return a single entry
QBFC_INFO_TYPES = %w{Company CompanyActivity Host Preferences ItemAssembliesCanBuild}

# Types that allow Special adds (Pre-defined and normally added automatically by QuickBooks)
QBFC_HAS_SPECIAL_ADD = %w{Account Item}

# TODO: Here and below arrays I haven't yet formed any approach to dealing with.
# I leave them here as a reminder.
ELEMENTS_ADD_MOD = %w{ DataExt }                  
                    
ELEMENTS_ADD_MOD_QUERY = %w{ DataExtDef }                    
                    
# Types that have their own DelRq
ELEMENT_DEL_TYPES = %w{DataEventRecoveryInfo DataExt DataExtDef}

module QBFC
  # Create QBElement classes
  (QBFC_TXN_TYPES + QBFC_LIST_TYPES + QBFC_ENTITY_TYPES + QBFC_ITEM_TYPES + QBFC_TERMS_TYPES + QBFC_REPORT_TYPES + QBFC_INFO_TYPES + QBFC_DELETE_ONLY + %w{DataExt DataExtDef Entity}).uniq.each do | qb_element_name |
    const_set(qb_element_name, Class.new(Base))
    
    const_get(qb_element_name).class_eval do
      const_set(:ALLOWS_READ, true)
    end
    
    unless (QBFC_NO_MOD_TYPES + QBFC_DELETE_ONLY).include?(qb_element_name)
      const_get(qb_element_name).class_eval do
        const_set(:ALLOWS_UPDATE, true)
      end
    end
  end
  
  (QBFC_TXN_TYPES + QBFC_LIST_TYPES + QBFC_ENTITY_TYPES + QBFC_ITEM_TYPES + QBFC_TERMS_TYPES).uniq.each do | qb_element_name |
    const_get(qb_element_name).class_eval do
      const_set(:ALLOWS_CREATE, true)
    end
  end
  
  QBFC_TXN_TYPES.each do | qb_element_name |
    const_get(qb_element_name).class_eval do
      const_set(:ALLOWS_DELETE, :txn)
    end
  end
  
  (QBFC_LIST_TYPES + QBFC_ENTITY_TYPES + QBFC_ITEM_TYPES + QBFC_TERMS_TYPES).each do | qb_element_name |
    const_get(qb_element_name).class_eval do
      const_set(:ALLOWS_DELETE, :list)
    end
  end

  ELEMENT_DEL_TYPES.each do | qb_element_name |
    const_get(qb_element_name).class_eval do
      const_set(:ALLOWS_DELETE, :element)
    end
  end
  
  QBFC_VOID_TYPES.each do | qb_element_name |
    const_get(qb_element_name).class_eval do
      const_set(:ALLOWS_VOID, true)
    end
  end
end