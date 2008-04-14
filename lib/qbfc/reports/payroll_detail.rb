module QBFC
  module Reports
    class PayrollDetail < QBFC::Report
      REPORT_TYPE_PREFIX = 'Pdrt'
      
      REPORTS = %w{EmployeeStateTaxesDetail
                   PayrollItemDetail
                   PayrollReviewDetail
                   PayrollTransactionDetail
                   PayrollTransactionsByPayee}
    end
  end
end