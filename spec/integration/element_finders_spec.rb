require 'spec_helper'

describe "QBFC::Element(finders)" do

  before(:each) do 
    @integration = QBFC::Integration::reader
    @sess = @integration.session
  end
  
  after(:each) do 
    @integration.close
  end
  
  it "should return a subclass of a base_class (e.g. Entity)" do
    entity = QBFC::Entity.find(@sess, "Bob Customer")
    entity.should be_kind_of(QBFC::Customer)
    entity.name.should == "Bob Customer"
  end
  
end
