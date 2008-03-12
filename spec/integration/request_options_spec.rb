require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# This spec describes use of the options to Element.find
# (except :conditions, which is in conditions_spec.rb)
# The implementation that this tests is Request#apply_options

describe "Request options: " do

  before(:each) do 
    @integration = QBFC::Integration::reader
    @sess = @integration.session
  end
  
  after(:each) do 
    @integration.close
  end
  
  describe "Invoice" do
    def assert_line_items
      inv.invoice_lines[0].desc == "First Line"
      inv.invoice_lines[1].desc == "Second Line"
      inv.invoice_lines[2].desc == "3rd Line"
    end
    
    def assert_linked_txns
      inv.linked_txn[0].ref_number.should == '1972'
      inv.linked_txn[0].amount.should == 1100.00    
    end
  
    it "should include line items" do
      inv = @sess.invoices.find(2, :include => [:line_items])
      assert_line_items
    end
    
    it "should include linked txns" do
      inv = @sess.invoices.find(2, :include => [:linked_txns])
      assert_linked_txns
    end
    
    it "should include include all (line items and linked txns)" do
      inv = @sess.invoices.find(2, :include => [:all])
      assert_line_items
      assert_linked_txns
    end
    
    it "should include a subset of elements" do
      inv = @sess.invoices.find(2,
          :include => [:txn_id, :customer_ref, :bill_address])
      inv.txn_id.should_not be_nil
      inv.customer_ref.full_name.should_not be_nil
      inv.bill_address.addr1.should_not be_nil
      
      inv.ref_number.should be_nil
      inv.class_ref.should be_nil
      inv.bill_address_block.should be_nil
    end
    
    it "should only txn_id" do
      inv = @sess.invoices.find(2,
          :include => [:txn_id])
      inv.txn_id.should_not be_nil

      inv.customer_ref.full_name.should be_nil
      inv.bill_address.addr1.should be_nil
    end
  end
  
end
