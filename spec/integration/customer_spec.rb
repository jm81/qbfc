require 'spec_helper'

describe "QBFC::Customer" do

  before(:each) do 
    @integration = QBFC::Integration::reader
    @sess = @integration.session
    @bob = @sess.customers.find_by_name("Bob Customer")
    @sue = @sess.customers.find_by_name("Sue Customer")
  end
  
  after(:each) do 
    @integration.close
  end

  it "should get name" do
    @bob.name.should == "Bob Customer"
    @sue.name.should == "Sue Customer"

    @bob.full_name.should == "Bob Customer"
    @sue.full_name.should == "Sue Customer"
  end
  
end

describe "QBFC::Customer(setters)" do
    
  before(:each) do 
    @integration = QBFC::Integration.new
    @sess = @integration.session
    @bob = @sess.customers.find_by_name("Bob Customer")
  end
  
  after(:each) do 
    @integration.close
  end
  
  it "should set name" do
    new_name = "New Customer"
    @bob.name = new_name
    @bob.name.should == new_name
    @bob.save
    
    @sess.customers.find(new_name).name.should == new_name
  end
end