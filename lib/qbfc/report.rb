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
        q.response
      end
      
      # The QuickBooks name for this Report.
      # It typically matches the last part of class name, plus 'Report'
      # Used in determining names of Requests and other OLE methods.
      def qb_name
        self.name.split('::').last + 'Report'
      end
    
      # Get a new Report.
      # This is roughly equivalent with QBFC::Element::find.
      # - <tt>sess</tt>: An open QBFC::Session object that will recieve all requests.
      # - <tt>name</tt>: The name of the report.
      # - <tt>args</tt>: TODO.
      def get(sess, name, *args)
        klass = get_class(name)
        klass.new(sess, klass.query(sess, name, *args))
      end
    end
    
    def rows
      @rows ||= QBFC::Reports::Rows::parse(@ole.report_data)
    end
    
    def data
      rows[:data]
    end
    
    def subtotals
      rows[:subtotals]
    end
    
    def totals
      rows[:totals]
    end
    
    def text_rows
      rows[:text]
    end
    
    def cell(row_name, col_name)
      rows[:data][row_name][col_for(col_name)]
    end
    
    def col_for(name)
      @ole.col_descs.each do |col|
        col.col_titles.each do |title|
          if title.value
            if (title.value.GetValue() == name)
              return col.colID.GetValue().to_i - 1
            end
          end
        end
      end
    end
  end
end

# Require subclass files
Dir.new(File.dirname(__FILE__) + '/reports').each do |file|
  require('qbfc/reports/' + File.basename(file)) if File.extname(file) == ".rb"
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
