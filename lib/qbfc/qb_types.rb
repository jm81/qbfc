# This file sets up the classes for QuickBooks entities, transactions and reports.

# List types that will inherit directly from QBFC::List
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
             
# List types that do not accept Mod Requests
QBFC_LIST_NO_MOD_TYPES = %w{ BillingRate CustomerMsg CustomerType DateDrivenTerms 
                             JobType PaymentMethod PayrollItemWage SalesTaxCode ShipMethod StandardTerms 
                             ToDo VendorType QBClass}

# Types that allow Query and Delete only
QBFC_DELETE_ONLY = %w{PayrollItemNonWage DataEventRecoveryInfo}

# Report types return an IReportRet
QBFC_REPORT_TYPES = %w{AgingReport BudgetSummaryReport CustomDetailReport CustomSummaryReport
                      GeneralDetailReport GeneralSummaryReport JobReport PayrollDetailReport PayrollSummaryReport TimeReport }

# Info Types support Query requests only and return a single entry
QBFC_INFO_TYPES = %w{Company CompanyActivity Host Preferences}

# Types that allow Special adds (Pre-defined and normally added automatically by QuickBooks)
QBFC_HAS_SPECIAL_ADD = %w{Account Item}

# TODO: Here and below arrays I haven't yet formed any approach to dealing with.
# I leave them here as a reminder.
ELEMENTS_ADD_MOD = %w{ DataExt }         
                    
ELEMENTS_ADD_MOD_QUERY = %w{ DataExtDef }
                    
# Types that have their own DelRq
ELEMENT_DEL_TYPES = %w{DataEventRecoveryInfo DataExt DataExtDef}

# Query types support Query requests only and return an itemized list of some sort;
# most of these may be integrated as special finders for their types.
QBFC_QUERY_TYPES =  %w{BillToPay ListDeleted ReceivePaymentToDeposit Template TxnDeleted SalesTaxPaymentCheck}

QBFC_ANOTHER_TO_INTEGRATE_SOMEWHERE = %w{ ItemAssembliesCanBuild }


module QBFC
  # Create QBElement classes
  (QBFC_LIST_TYPES + QBFC_ENTITY_TYPES + QBFC_ITEM_TYPES + QBFC_TERMS_TYPES + QBFC_REPORT_TYPES + QBFC_INFO_TYPES + QBFC_DELETE_ONLY + %w{DataExt DataExtDef Entity}).uniq.each do | qb_element_name |
    const_set(qb_element_name, Class.new(Base))
        
    unless (QBFC_LIST_NO_MOD_TYPES + QBFC_DELETE_ONLY).include?(qb_element_name)
      const_get(qb_element_name).class_eval do
        const_set(:ALLOWS_UPDATE, true)
      end
    end
  end
end