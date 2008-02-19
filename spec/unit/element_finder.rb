require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module QBFC::Test
  class BaseFind < QBFC::Element
    is_base_class
    
    def self.qb_class
      "Entity"
    end
  end
  
  class ElementFind < QBFC::Element
    def self.qb_class
      "Check"
    end
  end
end

# An Element is a Transaction or a List; that is any QuickBooks objects that can
# be created, edited (possibly), deleted and read. Contrast to a Report or Info
# which are read-only.
describe QBFC::Element do

  before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
    
    # Request related mocks
    @request = mock("QBFC::Request")
    @response = mock("QBFC::Request#response")
  end
  
  def setup_request
    QBFC::Request.should_receive(:new).with(@sess, 'CheckQuery').and_return(@request)
    @request.should_receive(:kind_of?).with(QBFC::Request).and_return(true)
    @request.should_receive(:response).and_return(@response)
    @response.stub!(:GetAt).with(0).and_return(@ole_wrapper)
    @response.stub!(:ole_methods).and_return(["GetAt"])
  end

  describe ".find" do
    it "should find_by_unique_id if the 'what' argument is neither :all nor :first" do
    it "should return only first entry if 'what' argument is :first"
    it "should set request#max_returned to 1 if :first"
    it "should return an array if 'what' argument is :all"
    it "should return nil if no elements are found unless finding :first"
    it "should return an empty array if no elements are found when finding :all"
    it "can accept a Request object"
    it "generates a Request object if not given one"
    it "accepts conditions"
    it "passes additional arguments to Request"
    it "should get request#response"
  end
end
