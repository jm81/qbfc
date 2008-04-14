module QBFC
  module Reports
    class BudgetSummary < QBFC::Report
      REPORT_TYPE_PREFIX = 'Bsrt'
      
      REPORTS = %w{BalanceSheetBudgetOverview 
                   BalanceSheetBudgetVsActual
                   ProfitAndLossBudgetOverview
                   ProfitAndLossBudgetPerformance
                   ProfitAndLossBudgetVsActual}
    end
  end
end