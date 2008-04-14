module QBFC
  # This class is EXPERIMENTAL!
  # This is a first stab at working with Reports.
  class Report < Base    
    class << self
      # Return the class that a report belongs to. Takes a string (or symbol) of
      # the report name. I could see refactoring this to use constants, later.
      def get_class(report_name)
        report_name = report_name.to_s
        CLASSES.find {|klass| klass::REPORTS.include?(report_name)}
      end
    end
  end
end

# Require subclass files
Dir[File.dirname(__FILE__) + '/reports/*.rb'].each do |file|
  require file
end

module QBFC
  class Report < Base
    # Set up CLASSES constant now that the referenced classes are loaded.
    CLASSES = [QBFC::Reports::Aging, QBFC::Reports::BudgetSummary,
               QBFC::Reports::CustomDetail, QBFC::Reports::CustomSummary,
               QBFC::Reports::GeneralDetail, QBFC::Reports::GeneralSummary,
               QBFC::Reports::Job, QBFC::Reports::PayrollDetail,
               QBFC::Reports::PayrollSummary, QBFC::Reports::Time]
  end
end
