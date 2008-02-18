require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module QBFC::Test
  class List < QBFC::List
    def self.qb_name
      "Account"
    end
  end
end

describe QBFC::List do

  before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
    @list = QBFC::Test::List.new(@sess, @ole_wrapper)
  end
  
  it "should specify if it is a superclass_list (such as Entity)"

  describe ".find" do
    it "should find_by_name_or_id if the first argument is neither :all nor :first"
    it "should return only first entry if first argument is :first"
    it "should set request#max_returned to 1 if :first"
    it "should return an array if first argument is :all"
    it "should return nil if no elements are found unless finding :all"
    it "should return an empty array if no elements are found when finding :all"
    it "can accept a Request object"
    it "generates a Request object if not given one"
    it "accepts conditions"
    it "passes additional arguments to Request"
    it "should get request#response"
    
    describe ".find(for base_class Lists)" do 
      it "should request only ListID"
      it "should send class ChildList::find_by_id with ListID and find options for each"
    end  
  end
  
  describe ".find_by_name" do    
    before(:each) do 
      @request = mock("QBFC::Request")
      @list_query = mock("QBFC::OLEWrapper#list_query")
      @full_name_list = mock("QBFC::OLEWrapper#full_name_list")
      @response = mock("QBFC::Request#response")
    end
  
    def setup_request
      QBFC::Request.should_receive(:new).with(@sess, 'AccountQuery').and_return(@request)
      @request.should_receive(:kind_of?).with(QBFC::Request).and_return(true)
      @request.should_receive(:kind_of?).with(Hash).and_return(false)
      @request.should_receive(:ORAccountListQuery).and_return(@list_query)
      @list_query.should_receive(:FullNameList).and_return(@full_name_list)
      @full_name_list.should_receive(:Add).with("Bob Customer")
      @request.should_receive(:response).and_return(@response)
      @response.stub!(:GetAt).with(0).and_return(@ole_wrapper)
      @response.stub!(:ole_methods).and_return(["GetAt"])
    end
  
    it "should set up Request, specifying FullNameList" do
      setup_request
      QBFC::Test::List.find_by_name(@sess, "Bob Customer")
    end
  
    it "should return a List object" do
      setup_request
      list = QBFC::Test::List.find_by_name(@sess, "Bob Customer")
      list.should be_kind_of(QBFC::Test::List)
    end
  
    it "should return nil if none found" do
      setup_request
      @response.should_receive(:GetAt).with(0).and_return(nil)
      QBFC::Test::List.find_by_name(@sess, "Bob Customer").should be_nil
    end
    
    it "should alias as find_by_full_name" do
      setup_request
      QBFC::Test::List.find_by_full_name(@sess, "Bob Customer")
    end
  end
  
  describe ".find_by_id" do
    it "should set up Request, specifying ListIDList"
    it "should process Request"
  end
  
  describe ".find_by_name_or_id" do
    it "should try to find_by_id"
    it "should try to find_by_name if id fails"
    it "should return nil if both name and id return nil"
  end
  
  describe "#id" do
    it "is an alias of list_id" do
      @ole_wrapper.should_receive(:list_id).and_return('L123')
      @list.id.should == 'L123'
    end
  end
  
  describe "#full_name" do
    before(:each) do
      @ole_wrapper.stub!(:full_name).and_return("Full Name")
      @ole_wrapper.stub!(:name).and_return("Short Name")
    end
    
    it "aliases name if not defined by OLE object" do
       @ole_wrapper.should_receive(:respond_to_ole?).with("FullName").and_return(false)
       @list.full_name.should == "Short Name"
    end
    
    it "calls OLE object's FullName method if defined" do
       @ole_wrapper.should_receive(:respond_to_ole?).with("FullName").and_return(true)
       @list.full_name.should == "Full Name"    
    end
  end
  
  describe "#delete" do
    it "should setup a ListDelRq with List Type and ID" do
      @del_rq = mock(QBFC::Request)
      @ole_wrapper.should_receive(:list_id).and_return('{123-456}')
      QBFC::Request.should_receive(:new).with(@sess, "ListDel").and_return(@del_rq)
      @del_rq.should_receive(:list_del_type=).with(QBFC_CONST::const_get("LdtAccount"))
      @del_rq.should_receive(:list_id=).with("{123-456}")
      @del_rq.should_receive(:submit)
      @list.delete.should be_true
    end
  end
  
  describe "#display" do
    it "should call ListDisplayAdd for new records"
    it "should call ListDisplayMod for existing records"
  end
end