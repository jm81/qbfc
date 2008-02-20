require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "QBFC::Element(finders)" do

  before(:each) do 
    @integration = QBFC::Integration::reader
    @sess = @integration.session
  end
  
  after(:each) do 
    @integration.close
  end

  it "return nil if no found is found when one is expected" do
    QBFC::Customer.find(@sess, "No Customer").should be_nil
  end
  
end
