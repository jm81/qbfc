require 'spec_helper'

describe "QBFC::Customer.new" do
    
  before(:each) do 
    @integration = QBFC::Integration.new
    @sess = @integration.session
  end
  
  after(:each) do 
    @integration.close
  end
  
  it "should create a new customer" do
    old_count = @sess.customers.find(:all).length

    c = @sess.customers.new
    c.name = "Cranky Customer"
    c.is_active = true
    c.last_name = "McCustomer"
    c.save
    
    n = @sess.customers.find("Cranky Customer")
    n.name.should == "Cranky Customer"
    n.is_active.should be(true)
    n.last_name.should == "McCustomer"
    
    @sess.customers.find(:all).length.should == old_count + 1
  end
  
end