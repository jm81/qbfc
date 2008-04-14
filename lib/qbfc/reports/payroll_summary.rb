module QBFC
  module Reports
    class PayrollSummary < QBFC::Report
      REPORT_TYPE_PREFIX = 'Psrt'
      
      REPORTS = %w{EmployeeEarningsSummary
                   PayrollLiabilityBalances
                   PayrollSummary}
    end
  end
end

                   