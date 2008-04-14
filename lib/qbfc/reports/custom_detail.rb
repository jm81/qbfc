module QBFC
  module Reports
    class CustomDetail < QBFC::Report
      REPORT_TYPE_PREFIX = 'Cdrt'
      
      REPORTS = %w{CustomTxnDetail}
    end
  end
end