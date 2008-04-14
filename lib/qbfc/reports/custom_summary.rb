module QBFC
  module Reports
    class CustomSummary < QBFC::Report
      REPORT_TYPE_PREFIX = 'Csrt'
      
      REPORTS = %w{CustomSummary}
    end
  end
end