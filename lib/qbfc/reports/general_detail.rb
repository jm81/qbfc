module QBFC
  module Reports
    class GeneralDetail < QBFC::Report
      REPORT_TYPE_PREFIX = 'Gdrt'
      
      REPORTS = %w{1099Detail
                   AuditTrail
                   BalanceSheetDetail
                   CheckDetail
                   CustomerBalanceDetail
                   DepositDetail
                   EstimatesByJob
                   ExpenseByVendorDetail
                   GeneralLedger
                   IncomeByCustomerDetail
                   IncomeTaxDetail
                   InventoryValuationDetail
                   JobProgressInvoicesVsEstimates
                   Journal
                   MissingChecks
                   OpenInvoices
                   OpenPOs
                   OpenPOsByJob
                   OpenSalesOrderByCustomer
                   OpenSalesOrderByItem
                   PendingSales
                   ProfitAndLossDetail
                   PurchaseByItemDetail
                   PurchaseByVendorDetail
                   SalesByCustomerDetail
                   SalesByItemDetail
                   SalesByRepDetail
                   TxnDetailByAccount
                   TxnListByCustomer
                   TxnListByDate
                   TxnListByVendor
                   UnpaidBillsDetail
                   UnbilledCostsByJob
                   VendorBalanceDetail}
    end
  end
end

                   