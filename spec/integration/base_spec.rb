require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QBFC::Base do

  before(:each) do 
    @integration = QBFC::Integration::reader
    @sess = @integration.session
  end
  
  after(:each) do 
    @integration.close
  end
  
  it "should do nothing" do
    true.should be_true
  end
  
end