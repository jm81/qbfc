require File.dirname(__FILE__) + '/../spec_helper'

describe "QBFC::Customer" do

  before(:each) do 
    @integration = QBFC::Integration.new
    @sess = @integration.session
    @bob = @sess.customers.find("Customer Bob")
    @sue = @sess.customers.find("Customer Sue")
  end
  
  after(:each) do 
    @integration.close
  end

  it "should get name" do
    @bob.name.should == "Customer Bob"
    @sue.name.should == "Customer Sue"

    @bob.full_name.should == "Customer Bob"
    @sue.full_name.should == "Customer Sue"
  end
  
  it "should set name" do
    new_name = "New Customer"
    @bob.name = new_name
    @bob.name.should == new_name
    @bob.save
    
    @sess.customers.find(new_name).name.should == new_name
  end
end