require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# This spec describes use of the :conditions option to Element.find
# The implementation that this tests is Request#apply_options

def run_test

  inv = @sess.invoices.find_by_ref('2', :include => [:line_items])
p inv.ORInvoiceLineRetList[0].InvoiceLineRet.desc
  inv.ORInvoiceLineRetList.Count
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
