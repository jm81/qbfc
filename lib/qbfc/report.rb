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
      
      # Run a query to retrieve a report. Typically called by +new+. See +new+
      # for arguments.
      def query(sess, name, *args)  
        # Setup q, options and base_options arguments (base_options is not used)
        q, options, base_options = parse_find_args(*args)
        q ||= create_query(sess)
        q.apply_options(options)
        q.send(qb_name + 'Type').
            SetValue(QBFC_CONST::const_get(self::REPORT_TYPE_PREFIX + name))
        q.response_xml
      end
      
      # The QuickBooks name for this Report.
      # It typically matches the last part of class name, plus 'Report'
      # Used in determining names of Requests and other OLE methods.
      def qb_name
        self.name.split('::').last + 'Report'
      end
    end
    
    # Create a new Report.
    # This is more equivalent with QBFC::Element::find than QBFC::Element::new,
    # since the report can not be modified or a new instance "created",
    # - <tt>sess</tt>: An open QBFC::Session object that will recieve all requests.
    # - <tt>name</tt>: The name of the report.
    # - <tt>args</tt>: TODO.
    def initialize(sess, name, *args)
      klass = self.class.get_class(name)
      if klass != self.class
        # Initialize report of appropriate class.
        klass.new(sess, name, *args)
      else
        @sess = sess
        self.class.query(sess, name, *args)
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
