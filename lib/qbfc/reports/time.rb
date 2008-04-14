module QBFC
  module Reports
    class Time < QBFC::Report
      REPORT_TYPE_PREFIX = 'Trt'
      
      REPORTS = %w{TimeByItem
                   TimeByJobDetail
                   TimeByJobSummary
                   TimeByName}
    end
  end
end