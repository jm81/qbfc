require File.dirname(__FILE__) + '/../spec_helper'

describe QBFC::Request do

  before(:each) do
    @sess = mock(QBFC::Session)
    @request_set = mock(WIN32OLE)
    @ole_request = mock(WIN32OLE)

    @sess.stub!(:CreateMsgSetRequest).and_return(@request_set)
    @request_set.stub!(:AppendCustomerQueryRq).and_return(@ole_request)
  end

  it "sends CreateMsgSetRequest to Quickbooks Session" do
    @sess.should_receive(:CreateMsgSetRequest).with('US', 6, 0).and_return(@request_set)
    QBFC::Request.new(@sess, 'CustomerQuery')
  end
  
  it "appends a query to MsgSetRequest" do
    @request_set.should_receive(:AppendCustomerQueryRq).and_return @ole_request
    QBFC::Request.new(@sess, 'CustomerQuery')
  end
  
  it "should wrap request object in OLEWrapper" do
    QBFC::OLEWrapper.should_receive(:new).with(@ole_request)
    QBFC::Request.new(@sess, 'CustomerQuery')
  end

  it "accepts version information" do
    @sess.should_receive(:CreateMsgSetRequest).with('CA', 5, 5).and_return(@request_set)
    QBFC::Request.new(@sess, 'CustomerQuery', 'CA', 5, 5)
  end
  
  it "should raise a QBFC::QBXMLVersionError if the version is not supported" do
    @sess.should_receive(:CreateMsgSetRequest).and_raise(WIN32OLERuntimeError.new('error code:8004030A'))
    lambda { QBFC::Request.new(@sess, 'CustomerQuery')}.should raise_error(QBFC::QBXMLVersionError)
  end
  
  it "should raise a QBFC::UnknownRequestError if the request is not supported" do
    @request_set.should_receive(:AppendCustomerQueryRq).and_raise(WIN32OLERuntimeError.new('error code:0x80020006'))
    lambda { QBFC::Request.new(@sess, 'CustomerQuery')}.should raise_error(QBFC::UnknownRequestError)
  end
  
  it "should show ole_methods" do
    @ole_request.should_receive(:ole_methods)
    QBFC::Request.new(@sess, 'CustomerQuery').ole_methods
  end
  
  it "should return xml of the request" do
    @request_set.should_receive(:ToXMLString)
    QBFC::Request.new(@sess, 'CustomerQuery').to_xml
  end
  
  describe "QBFC::Request#response" do
    before(:each) do
      @sess = mock(QBFC::Session)
      @request_set = mock(WIN32OLE)
      @ole_request = mock(WIN32OLE)
  
      @sess.stub!(:CreateMsgSetRequest).and_return(@request_set)
      @request_set.stub!(:AppendCustomerQueryRq).and_return(@ole_request)
    
      @response_set = mock("DoRequestsRespost")
      @response_list = mock("ResponseList")
      @response = mock("GetAt")
      @detail = mock("Detail")
      
      @sess.stub!(:DoRequests).and_return @response_set
      @response_set.stub!(:ResponseList).and_return @response_list
      @response_list.stub!(:GetAt).and_return @response
      @response.stub!(:Detail).and_return @detail
    end
  
    it "gets a response" do
      @sess.should_receive(:DoRequests).and_return @response_set
      @response_set.should_receive(:ResponseList).and_return @response_list
      @response_list.should_receive(:GetAt).with(0).and_return @response
      @response.should_receive(:Detail).and_return @detail

      request = QBFC::Request.new(@sess, 'CustomerQuery')

      request.response.should be_kind_of(QBFC::OLEWrapper)
    end
    
    it "returns a nil response if the response has no Detail" do
      @response.should_receive(:Detail).and_return nil
    
      request = QBFC::Request.new(@sess, 'CustomerQuery')
      
      QBFC::OLEWrapper.should_not_receive(:new)
      request.response.should be_nil
    end
    
      
    it "should return xml of the response" do
      request = QBFC::Request.new(@sess, 'CustomerQuery')      
      @response_set.should_receive(:ToXMLString)
      request.response_xml
    end
  end

end