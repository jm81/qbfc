# This file sets up the classes for QuickBooks entities, transactions and reports.

# Types that allow Query and Delete only
QBFC_DELETE_ONLY = %w{DataEventRecoveryInfo}

# Report types return an IReportRet
QBFC_REPORT_TYPES = %w{AgingReport BudgetSummaryReport CustomDetailReport CustomSummaryReport
                      GeneralDetailReport GeneralSummaryReport JobReport PayrollDetailReport PayrollSummaryReport TimeReport }

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
  (QBFC_REPORT_TYPES + QBFC_DELETE_ONLY + %w{DataExt DataExtDef}).uniq.each do | qb_element_name |
    const_set(qb_element_name, Class.new(Base))
  end
end