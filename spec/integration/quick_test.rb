require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# This spec describes use of the :conditions option to Element.find
# The implementation that this tests is Request#apply_options

def run_test
          @sess.report('ProfitAndLossStandard',
            :report_date_range => [Date.parse("2007-08-01"), Date.parse("2007-08-31")],
            :report_basis => QBFC_CONST::RbAccrual)
end

# Setup
use_open = true

if use_open
  @sess = QBFC::Session.new
else
  @integration = QBFC::Integration::reader
  @sess = @integration.session
end

begin
  puts run_test
ensure
  if use_open
    @sess.close
  else
    @integration.close
  end
end
