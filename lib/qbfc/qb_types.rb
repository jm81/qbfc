# This file sets up the classes for QuickBooks entities, transactions and
# reports that are not setup elsewhere (at this point, this file is only used
# for "weird" classes.

# Very non-standard elements.  I haven't yet formed an approach to dealing
# with these; I leave them here as a reminder.
QBFC_NON_STANDARD_TYPES = %w{ DataExt DataExtDef DataEventRecoveryInfo ItemAssembliesCanBuild}

# Query types support Query requests only and return an itemized list of some sort;
# most of these may be integrated as special finders for their types.
QBFC_QUERY_TYPES =  %w{BillToPay ListDeleted ReceivePaymentToDeposit Template TxnDeleted}

module QBFC
  # Create QBElement classes
  (QBFC_NON_STANDARD_TYPES + QBFC_QUERY_TYPES).uniq.each do | qb_element_name |
    const_set(qb_element_name, Class.new(Base))
  end
end