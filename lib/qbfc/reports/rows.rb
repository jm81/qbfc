module QBFC
  module Reports
    class Rows < Array
      class << self
        def get_row(cols)
          ret = []
          if cols
            cols.each do |col|
              ret << col.value.getValue
            end
          end
          ret
        end
  
        def parse(report_data)
          data = []
          subtotals = []
          totals = []
          text = []
          
          report_data.o_r_report_datas.each do |d|
            if d.DataRow
              data << get_row(d.DataRow.col_datas)
            elsif d.TextRow
              text << d.TextRow.value.getValue
            elsif d.SubtotalRow
              subtotals << get_row(d.SubtotalRow.col_datas)
            elsif d.TotalRow
              totals << get_row(d.TotalRow.col_datas)
            end
  
          end
          
          return {:data => new(data), 
                  :subtotals => new(subtotals),
                  :text => text,
                  :totals => new(totals)}
        end 
      end
            
      def [](value)
        if value.kind_of? String
          self.detect{ |entry| entry[0] == value }
        else
          super
        end
      end
          
    end
  end
end