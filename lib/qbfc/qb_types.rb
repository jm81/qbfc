# This file sets up the classes for QuickBooks entities, transactions and reports.

# Report types return an IReportRet
QBFC_REPORT_TYPES = %w{AgingReport BudgetSummaryReport CustomDetailReport
    CustomSummaryReport GeneralDetailReport GeneralSummaryReport JobReport
    PayrollDetailReport PayrollSummaryReport TimeReport }

# Very non-standard elements.  I haven't yet formed an approach to dealing
# with these; I leave them here as a reminder.
QBFC_NON_STANDARD_TYPES = %w{ DataExt DataExtDef DataEventRecoveryInfo ItemAssembliesCanBuild}

# Query types support Query requests only and return an itemized list of some sort;
# most of these may be integrated as special finders for their types.
QBFC_QUERY_TYPES =  %w{BillToPay ListDeleted ReceivePaymentToDeposit Template TxnDeleted SalesTaxPaymentCheck}

module QBFC
  # Create QBElement classes
  (QBFC_REPORT_TYPES + QBFC_NON_STANDARD_TYPES + QBFC_QUERY_TYPES).uniq.each do | qb_element_name |
    const_set(qb_element_name, Class.new(Base))
  end
end