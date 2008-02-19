require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "QBFC::Customer" do

  before(:each) do 
    @integration = QBFC::Integration::reader
    @sess = @integration.session
    @bob = @sess.customers.find_by_name("Customer Bob")
    @sue = @sess.customers.find_by_name("Customer Sue")
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
  
  describe "(setters)" do
    
    before(:each) do 
      @integration = QBFC::Integration.new
      @sess = @integration.session
      @bob = @sess.customers.find_by_name("Customer Bob")
    end
    
    it "should set name" do
      new_name = "New Customer"
      @bob.name = new_name
      @bob.name.should == new_name
      @bob.save
      
      @sess.customers.find(new_name).name.should == new_name
    end
  end
end