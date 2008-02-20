require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module QBFC::Test
  class ListFind < QBFC::List
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

    # Request related mocks
    @request = mock("QBFC::Request")
    @list_query = mock("QBFC::OLEWrapper#list_query")
    @response = mock("QBFC::Request#response")
    
    # Filter mock
    @filter = mock("QBFC::OLEWrapper#Filter")
    @request.stub!(:filter).and_return(@filter)
    @filter.stub!(:max_returned=)
    @request.stub!(:filter_available?).and_return(true)
  end
  
  def setup_request
    QBFC::Request.should_receive(:new).with(@sess, 'AccountQuery').and_return(@request)
    @request.should_receive(:kind_of?).with(QBFC::Request).and_return(true)
    @request.stub!(:response).and_return(@response)
    @response.stub!(:GetAt).with(0).and_return(@ole_wrapper)
    @response.stub!(:ole_methods).and_return(["GetAt"])
  end

  describe ".find" do    
    describe ".find(for base_class Lists)" do 
      it "should request only ListID"
      it "should send class ChildList::find_by_id with ListID and find options for each"
    end  
  end
  
  describe ".find_by_name" do    
    before(:each) do 
      @full_name_list = mock("QBFC::OLEWrapper#full_name_list")
    end
    
    def setup_request
      super
      @request.should_receive(:ORAccountListQuery).and_return(@list_query)
      @list_query.should_receive(:FullNameList).and_return(@full_name_list)
      @full_name_list.should_receive(:Add).with("Bob Customer")
    end
    
    it "should set up Request, specifying FullNameList" do
      setup_request
      QBFC::Test::ListFind.find_by_name(@sess, "Bob Customer")
    end
  
    it "should return a List object" do
      setup_request
      list = QBFC::Test::ListFind.find_by_name(@sess, "Bob Customer")
      list.should be_kind_of(QBFC::Test::ListFind)
    end
  
    it "should return nil if none found" do
      setup_request
      @request.should_receive(:response).and_return(nil)
      QBFC::Test::ListFind.find_by_name(@sess, "Bob Customer").should be_nil
    end
    
    it "should alias as find_by_full_name" do
      setup_request
      QBFC::Test::ListFind.find_by_full_name(@sess, "Bob Customer")
    end
  end
  
  describe ".find_by_id" do
    before(:each) do 
      @list_id_list = mock("QBFC::OLEWrapper#list_id_list")
    end
    
    def setup_request
      super
      @request.should_receive(:ORAccountListQuery).and_return(@list_query)
      @list_query.should_receive(:ListIDList).and_return(@list_id_list)
      @list_id_list.should_receive(:Add).with("123-456")
    end
    
    it "should set up Request, specifying ListIDList" do
      setup_request
      QBFC::Test::ListFind.find_by_id(@sess, "123-456")
    end
  
    it "should return a List object" do
      setup_request
      list = QBFC::Test::ListFind.find_by_id(@sess, "123-456")
      list.should be_kind_of(QBFC::Test::ListFind)
    end
  
    it "should return nil if none found" do
      setup_request
      @request.should_receive(:response).and_return(nil)
      QBFC::Test::ListFind.find_by_id(@sess, "123-456").should be_nil
    end
  end
  
  describe ".find_by_name_or_id" do    
    it "should try to find_by_id" do
      QBFC::Test::ListFind.should_receive(:find_by_id).with(@sess, "123-456").and_return("List By ID")
      QBFC::Test::ListFind.find_by_name_or_id(@sess, "123-456").should == "List By ID"
    end
    
    it "should try to find_by_name if id fails" do
      QBFC::Test::ListFind.should_receive(:find_by_id).with(@sess, "123-456").and_return(nil)
      QBFC::Test::ListFind.should_receive(:find_by_name).with(@sess, "123-456").and_return("List By Name")
      QBFC::Test::ListFind.find_by_name_or_id(@sess, "123-456").should == "List By Name"
    end
    
    it "should return nil if both name and id return nil" do
      QBFC::Test::ListFind.should_receive(:find_by_id).with(@sess, "123-456").and_return(nil)
      QBFC::Test::ListFind.should_receive(:find_by_name).with(@sess, "123-456").and_return(nil)
      QBFC::Test::ListFind.find_by_name_or_id(@sess, "123-456").should be_nil
    end

    it "should be aliased as .find_by_unique_id" do
      QBFC::Test::ListFind.should_receive(:find_by_id).with(@sess, "123-456").and_return(nil)
      QBFC::Test::ListFind.should_receive(:find_by_name).with(@sess, "123-456").and_return(nil)
      QBFC::Test::ListFind.find_by_unique_id(@sess, "123-456").should be_nil
    end
  end
end