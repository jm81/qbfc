module QBFC
  module Reports
    class GeneralSummary < QBFC::Report
      REPORT_TYPE_PREFIX = 'Gsrt'
      
      REPORTS = %w{BalanceSheetPrevYearComp
                   BalanceSheetStandard
                   BalanceSheetSummary
                   CustomerBalanceSummary
                   ExpenseByVendorSummary
                   IncomeByCustomerSummary
                   InventoryStockStatusByItem
                   InventoryStockStatusByVendor
                   IncomeTaxSummary
                   InventoryValuationSummary
                   PhysicalInventoryWorksheet
                   ProfitAndLossByClass
                   ProfitAndLossByJob
                   ProfitAndLossPrevYearComp
                   ProfitAndLossStandard
                   ProfitAndLossYTDComp
                   PurchaseByItemSummary
                   PurchaseByVendorSummary
                   SalesByCustomerSummary
                   SalesByItemSummary
                   SalesByRepSummary
                   SalesTaxLiability
                   SalesTaxRevenueSummary
                   TrialBalance
                   VendorBalanceSummary}
    end
  end
end