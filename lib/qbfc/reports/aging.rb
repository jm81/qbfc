module QBFC
  module Reports
    class Aging < QBFC::Report
      REPORT_TYPE_PREFIX = 'Art'
      
      REPORTS = %w{APAgingDetail
                   APAgingSummary
                   ARAgingDetail
                   ARAgingSummary
                   CollectionsReport}
    end
  end
end