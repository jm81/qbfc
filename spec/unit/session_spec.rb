require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QBFC::Session do

  before(:each) do
    @ole_object = mock("WIN32OLE")
    @ole_object.stub!(:OpenConnection2)
    @ole_object.stub!(:BeginSession)    
    WIN32OLE.stub!(:new).and_return(@ole_object)
    
    @ole_wrapper = mock(QBFC::OLEWrapper)
    QBFC::OLEWrapper.stub!(:new).and_return(@ole_wrapper)
    
    @qb_sess = QBFC::Session.new()
  end

  it "should create an QBFC WIN32OLE object" do
    WIN32OLE.should_receive(:new).with("QBFC6.QBSessionManager").and_return(@ole_object)
    QBFC::Session.new()
  end
  
  it "should wrap WIN32OLE object" do
    QBFC::OLEWrapper.should_receive(:new).with(@ole_object)
    QBFC::Session.new()  
  end

  it "should open connection to Quickbooks and establish a session" do
    @ole_object.should_receive(:OpenConnection2)
    QBFC::Session.new()
  end
  
  it "should begin a session with Quickbooks" do
    @ole_object.should_receive(:BeginSession)
    QBFC::Session.new()
  end
  
  it "should raise an error if session can't be established" do
    @ole_object.should_receive(:BeginSession).and_raise(WIN32OLERuntimeError)
    @ole_object.should_receive(:CloseConnection)
    lambda { QBFC::Session.new }.should raise_error(QBFC::QuickbooksClosedError)
  end
  
  it "should accept an app_name option" do
    @ole_object.should_receive(:OpenConnection2).with('', 'Test Application', 1)
    QBFC::Session.new(:app_name => 'Test Application')
  end
  
  it "should accept an app_id option" do
    @ole_object.should_receive(:OpenConnection2).with('ID', 'Test Application', 1)
    QBFC::Session.new(:app_name => 'Test Application', :app_id => 'ID')
  end
  
  it "should accept a conn_type option" do
    @ole_object.should_receive(:OpenConnection2).with('', 'Test Application', 0)
    QBFC::Session.new(:app_name => 'Test Application', :conn_type => QBFC_CONST::CtUnknown)  
  end
  
  it "should accept an open mode constant" do
    @ole_object.should_receive(:BeginSession).with('', 0)
    QBFC::Session.new(:open_mode => QBFC_CONST::OmSingleUser )
    
    @ole_object.should_receive(:BeginSession).with('', 1)
    QBFC::Session.new(:open_mode => QBFC_CONST::OmMultiUser)

    @ole_object.should_receive(:BeginSession).with('', 2)
    QBFC::Session.new(:open_mode => QBFC_CONST::OmDontCare)
  end
  
  it "should accept a filename option" do
    @ole_object.should_receive(:BeginSession).with('TestCompany.qbw', 2)
    QBFC::Session.new(:filename => 'TestCompany.qbw')
  end
    
  it "should close session and connection on close" do
    @ole_wrapper.should_receive(:EndSession)
    @ole_wrapper.should_receive(:CloseConnection)
    @qb_sess.close()
  end
  
  describe "::open" do
    
    before(:each) do
      @ole_wrapper.stub!(:EndSession)
      @ole_wrapper.stub!(:CloseConnection)
    end
  
    it "should accept a block" do
      QBFC::Session.open do |qb|
        qb.should be_kind_of(QBFC::Session)
      end
    end
    
    it "should return session if called without a block" do
      QBFC::Session.open.should be_kind_of(QBFC::Session)
    end
  end
  
  it "should create an instance of QBFC::Base descendant from a singular method with params" do
    @base = mock(QBFC::Base)
    QBFC::Customer.should_receive(:find_by_full_name_or_list_id).with(@qb_sess, '1234-5678').and_return(@base)
    @qb_sess.customer('1234-5678').should == @base
    
    QBFC::Vendor.should_receive(:find_by_full_name_or_list_id).with(@qb_sess, '1234-5678').and_return(@base)
    @qb_sess.vendor('1234-5678').should == @base
  end

  it "should create an instance of QBFC::Base descendant from a singular method" do
    @base = mock(QBFC::Base)
    QBFC::Customer.should_receive(:find).with(@qb_sess, :first).and_return(@base)
    @qb_sess.customer.should == @base
  end
  
  it "should create an instance of QBFC::QBCollection a plural method" do
    @collection = mock(QBFC::QBCollection)
    QBFC::QBCollection.should_receive(:new).with(@qb_sess, :Customer).and_return(@collection)
    @qb_sess.customers.should == @collection
    
    QBFC::QBCollection.should_receive(:new).with(@qb_sess, :Vendor).and_return(@collection)
    @qb_sess.vendors.should == @collection
  end
  
  it "should let OLEWrapper handle other unknown methods" do
    @ole_wrapper.should_receive(:qbfc_method_missing).with(@qb_sess, :FullName).and_return(true)
    @qb_sess.FullName

    @ole_wrapper.should_receive(:qbfc_method_missing).with(@qb_sess, :full_name).and_return(true)
    @qb_sess.full_name
    
    @ole_wrapper.should_receive(:qbfc_method_missing).with(@qb_sess, :full_name=, 'Full Name').and_return(true)
    @qb_sess.full_name = 'Full Name'
  end
end