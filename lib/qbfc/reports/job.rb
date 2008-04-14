module QBFC
  module Reports
    class Job < QBFC::Report
      REPORT_TYPE_PREFIX = 'Jrt'
      
      REPORTS = %w{ItemEstimatesVsActuals
                   ItemProfitability
                   JobEstimatesVsActualsDetail
                   JobEstimatesVsActualsSummary
                   JobProfitabilityDetail
                   JobProfitabilitySummary}
    end
  end
end