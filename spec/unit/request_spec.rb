require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QBFC::Request do

  before(:each) do
    @sess = mock(QBFC::Session)
    @request_set = mock(QBFC::OLEWrapper)
    @ole_request = mock(QBFC::OLEWrapper)

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

  it "accepts version information" do
    @sess.should_receive(:CreateMsgSetRequest).with('CA', 5, 5).and_return(@request_set)
    QBFC::Request.new(@sess, 'CustomerQuery', 'CA', 5, 5)
  end
  
  it "should raise a QBFC::QBXMLVersionError if the version is not supported" do
    @sess.should_receive(:CreateMsgSetRequest).and_raise(WIN32OLERuntimeError.new('error code:8004030A'))
    lambda { QBFC::Request.new(@sess, 'CustomerQuery')}.should raise_error(QBFC::QBXMLVersionError)
  end
  
  it "should re-raise errors other than QBXMLVersionError" do
    @sess.should_receive(:CreateMsgSetRequest).and_raise(WIN32OLERuntimeError.new('error'))
    lambda { QBFC::Request.new(@sess, 'CustomerQuery')}.should raise_error(WIN32OLERuntimeError)
  end
    
  it "should raise a QBFC::UnknownRequestError if the request is not supported" do
    @request_set.should_receive(:AppendCustomerQueryRq).and_raise(WIN32OLERuntimeError.new('error code:0x80020006'))
    lambda { QBFC::Request.new(@sess, 'CustomerQuery')}.should raise_error(QBFC::UnknownRequestError)
  end
    
  it "should re-raise errors other than UnknownRequestError" do
    @request_set.should_receive(:AppendCustomerQueryRq).and_raise(WIN32OLERuntimeError.new('error'))
    lambda { QBFC::Request.new(@sess, 'CustomerQuery')}.should raise_error(WIN32OLERuntimeError)
  end
  
  it "should show ole_methods" do
    @ole_request.should_receive(:ole_methods)
    QBFC::Request.new(@sess, 'CustomerQuery').ole_methods
  end
  
  it "gives direct access to the request's ole_object" do
    @ole_request.should_receive(:ole_object).and_return("OLEObject")
    QBFC::Request.new(@sess, 'CustomerQuery').ole_object.should == "OLEObject"
  end
  
  it "should have the OLEWrapper object handle missing methods" do
    @ole_request.should_receive(:qbfc_method_missing).with(@sess, :no_method)
    QBFC::Request.new(@sess, 'CustomerQuery').no_method

    @ole_request.should_receive(:qbfc_method_missing).with(@sess, :NoMethod)
    QBFC::Request.new(@sess, 'CustomerQuery').NoMethod
  end
  
  it "should return xml of the request" do
    @request_set.should_receive(:ToXMLString)
    QBFC::Request.new(@sess, 'CustomerQuery').to_xml
  end
  
  describe "#response" do
    before(:each) do
      @sess = mock(QBFC::Session)
      @request_set = mock(QBFC::OLEWrapper)
      @ole_request = mock(QBFC::OLEWrapper)
  
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

      request.response.should == @detail
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
  
  describe "#query" do
    before(:each) do
      @request = QBFC::Request.new(@sess, 'CustomerQuery')
      @request.instance_variable_set(:@request, @ole_request)
      
      @or_query = mock("OLEWrapper#or_query")    
    end
  
    it "gets the OR*Query for the given Request" do
      @ole_request.should_receive(:ole_methods).and_return(["TxnID", "RefNumber", "ORTransactionQuery", "OwnerIDList"])
      @ole_request.should_receive(:ORTransactionQuery).and_return(@or_query)
      @request.query.should be(@or_query)
    end
    
    it "should return nil if no query name is detected" do
      @ole_request.should_receive(:ole_methods).and_return(["TxnID", "RefNumber", "OwnerIDList"])
      @request.query.should be_nil
    end
  end
  
  describe "#filter" do
    before(:each) do
      @request = QBFC::Request.new(@sess, 'CustomerQuery')
      @request.instance_variable_set(:@request, @ole_request)
      
      @or_query = mock("OLEWrapper#or_query")
      @filter = mock("OLEWrapper#filter")
      @ole_request.stub!(:ole_methods).and_return(["TxnID", "RefNumber", "ORTransactionQuery", "OwnerIDList"])
      @ole_request.stub!(:ORTransactionQuery).and_return(@or_query)
    end

    it "gets the *Filter for the given Request" do
      @or_query.should_receive(:ole_methods).and_return(["TxnIDList", "RefNumberList", "TransactionFilter"])
      @or_query.should_receive(:TransactionFilter).and_return(@filter)
      @request.filter.should be(@filter)
    end
    
    it "should return nil if no filter name is detected" do
      @or_query.should_receive(:ole_methods).and_return(["TxnIDList", "RefNumberList"])
      @request.filter.should be_nil
    end
    
    it "should return nil if the #query is nil" do
      @ole_request.should_receive(:ole_methods).and_return([])
      @request.filter.should be_nil
    end
  end

  describe "#filter_available?" do
    before(:each) do
      @request = QBFC::Request.new(@sess, 'CustomerQuery')
      
      @or_query = mock("OLEWrapper#or_query")
      @filter = mock("OLEWrapper#filter")
      @ole_request.stub!(:ole_methods).and_return(["TxnID", "RefNumber", "ORTransactionQuery", "OwnerIDList", "ortype"])
      @ole_request.stub!(:ORTransactionQuery).and_return(@or_query)
      
      @ole_object = mock(WIN32OLE)
      @or_query.stub!(:ole_object).and_return(@ole_object)
      @ole_object.stub!(:ole_object).and_return(["TxnID", "RefNumber", "ORTransactionQuery", "OwnerIDList", "ortype"])
    end

    it "should be true if no query options have been set" do
      @ole_object.should_receive(:ortype).at_least(:once).and_return(-1)
      @request.filter_available?.should be_true
    end
    
    it "should be true if Filter option has been set" do
      @ole_object.should_receive(:ortype).at_least(:once).and_return(2)
      @request.filter_available?.should be_true
    end
    
    it "should be false if a *List option has been set" do
      @ole_object.should_receive(:ortype).at_least(:once).and_return(1)
      @request.filter_available?.should be_false
    end
    
  end
  
  describe "#apply_options" do
    before(:each) do
      @request = QBFC::Request.new(@sess, 'CustomerQuery')
      @query = mock('Request#query')
      @filter = mock('Request#filter')
      @request.stub!(:query).and_return(@query)
    end
  
    it "should apply an :owner_id option" do
      @request.should_receive(:add_owner_ids).with(1)
      @request.apply_options(:owner_id => 1)
    end

    it "should apply an :limit option" do
      @request.should_receive(:add_limit).with(1)
      @request.apply_options(:limit => 1)
    end
    
    it "should apply lists to query" do
      ref_number_list = mock('OLEWrapper#ref_number_list')
      @query.should_receive(:RefNumberList).and_return(ref_number_list)
      ref_number_list.should_receive(:Add).with('82')
      ref_number_list.should_receive(:Add).with('1234')

      @request.apply_options(:conditions => {:ref_number_list => %w{82 1234}})
    end

    it "should apply lists to query when given a single item" do
      ref_number_list = mock('OLEWrapper#ref_number_list')
      @query.should_receive(:RefNumberList).and_return(ref_number_list)
      ref_number_list.should_receive(:Add).with('20')

      @request.apply_options(:conditions => {:ref_number_list => '20'})
    end
    
    describe "(range)" do
      before(:each) do
        @range_filter = mock('Request#TxnDateRangeFilter')
        @request.stub!(:filter_for).with('txn_date_range').and_return(@range_filter)
        @request.stub!(:filter_for).with('modified_date_range').and_return(@range_filter)
        @range_filter.stub!(:from_txn_date=)
        @range_filter.stub!(:to_txn_date=)
      end
    
      it "should #parse_range_value" do
        @request.should_receive(:parse_range_value).with([0,2]).and_return([0,2])
        @request.apply_options(:conditions => {:txn_date_range => [0,2]})
      end
      
      it "should get appropriate filter" do
        @request.should_receive(:filter_for).with('txn_date_range').and_return(@range_filter)
        @request.apply_options(:conditions => {:txn_date_range => [0,2]})
      end
      
      it "should apply date range to filter" do
        @range_filter.should_receive(:from_txn_date=).with(0)
        @range_filter.should_receive(:to_txn_date=).with(2)
        @request.apply_options(:conditions => {:txn_date_range => [0,2]})
      end

      it "should add 'true' argument (asDateOnly) for modified_date ranges" do
        @range_filter.should_receive(:from_modified_date=).with(0, true)
        @range_filter.should_receive(:to_modified_date=).with(2, true)
        @request.apply_options(:conditions => {:modified_date_range => [0,2]})
      end
    end
    
    describe "(reference)" do
      before(:each) do
        @ref_filter = mock('Request#RefFilter')
        @full_name_list = mock('OLEWrapper#FullNameList')
        @request.stub!(:filter_for).with('entity').and_return(@ref_filter)
        @ref_filter.should_receive(:FullNameList).at_least(:once).and_return(@full_name_list)
        @full_name_list.stub!(:Add)
      end
    
      it "should get appropriate filter" do
        @request.should_receive(:filter_for).with('entity').and_return(@ref_filter)
        @request.apply_options(:conditions => {:entity => 'ABC Supplies'})
      end
      
      it "should set a single full name" do
        @full_name_list.should_receive(:Add).with('ABC Supplies')
        @request.apply_options(:conditions => {:entity => 'ABC Supplies'})
      end

      it "should set a single full name (non-string)" do
        @full_name_list.should_receive(:Add).with(1)
        @request.apply_options(:conditions => {:entity => 1})
      end
      
      it "should set a multiple full names" do
        @full_name_list.should_receive(:Add).with('ABC Supplies')
        @full_name_list.should_receive(:Add).with('CompuStuff')
        @request.apply_options(:conditions => {:entity => %w{ABC\ Supplies CompuStuff}})
      end
    end
  end
  
  describe "#parse_range_value" do
    before(:each) do
      @request = QBFC::Request.new(@sess, 'CustomerQuery')
    end

    it "should add a nil element to a one-element Array" do
      ary = [0]
      @request.__send__(:parse_range_value, ary).should == [0, nil]
    end
    
    it "should return unchanged a multiple element Array" do
      ary = [0, 1]
      @request.__send__(:parse_range_value, ary).should be(ary)
    end
    
    it "should return unchanged a Range" do
      rng = 0..1
      @request.__send__(:parse_range_value, rng).should be(rng)
    end
    
    it "should take a scalar and return an array with the second element nil" do
      val = 0
      @request.__send__(:parse_range_value, val).should == [val, nil]
    end
    
    it "should take a String scalar and return an array with the second element nil" do
      val = '0'
      @request.__send__(:parse_range_value, val).should == [val, nil]
    end
  
  end
  
  describe "#filter_for" do
    before(:each) do
      @request = QBFC::Request.new(@sess, 'CustomerQuery')
      @query = mock('Request#query')
      @filter = mock('Request#filter')
      @request.stub!(:query).and_return(@query)
      @request.stub!(:filter).and_return(@filter)

      @or_date_range_filter = mock('Request#ORDateRangeFilter')
      @or_ref_number_filter = mock('Request#ORRefNumberFilter')
      @txn_date_range_filter = mock('Request#TxnDateRangeFilter')
      @final_filter = mock('Request#FinalFilter')
      
      @filter.stub!(:respond_to_ole?).and_return(false)
      @or_date_range_filter.stub!(:respond_to_ole?).and_return(false)
      @final_filter.stub!(:respond_to_ole?).and_return(false)
    end
  
    it "should follow ORDateRangeFilter for date_ranges" do
      @filter.should_receive(:respond_to_ole?).with('ORDateRangeFilter').and_return(true)
      @filter.should_receive(:ORDateRangeFilter).and_return(@or_date_range_filter)
      @or_date_range_filter.should_receive(:ModifiedDateRangeFilter).and_return(@final_filter)
      
      @request.__send__(:filter_for, 'modified_date_range').should be(@final_filter)
    end

    it "should follow OR{name}Filter" do
      @filter.should_receive(:respond_to_ole?).with('ORRefNumberFilter').and_return(true)
      @filter.should_receive(:ORRefNumberFilter).and_return(@or_ref_number_filter)
      @or_ref_number_filter.should_receive(:RefNumberFilter).and_return(@final_filter)
      
      @request.__send__(:filter_for, 'ref_number').should be(@final_filter)
    end
    
    it "should follow OR{name}Filter, with 'Range' removed" do
      @filter.should_receive(:respond_to_ole?).with('ORRefNumberFilter').and_return(true)
      @filter.should_receive(:ORRefNumberFilter).and_return(@or_ref_number_filter)
      @or_ref_number_filter.should_receive(:RefNumberRangeFilter).and_return(@final_filter)
      
      @request.__send__(:filter_for, 'ref_number_range').should be(@final_filter)
    end
    
    it "should return #filter if *ModifiedDate in #filter" do
      @filter.should_receive(:respond_to_ole?).with('FromModifiedDate').and_return(true)
      @request.__send__(:filter_for, 'modified_date_range').should == @filter
    end
    
    it "should follow OR below the Filter" do
      @filter.should_receive(:respond_to_ole?).with('TxnDateRangeFilter').and_return(true)
      @filter.should_receive(:TxnDateRangeFilter).and_return(@txn_date_range_filter)
      
      @txn_date_range_filter.should_receive(:respond_to_ole?).with('ORTxnDateRangeFilter').and_return(true)
      @txn_date_range_filter.should_receive(:ORTxnDateRangeFilter).and_return(@or_date_range_filter)
      
      @request.__send__(:filter_for, 'txn_date_range').should be(@or_date_range_filter)
    end

    it "should get a nested Filter with 'Range' removed" do
      @filter.should_receive(:respond_to_ole?).with('TxnDateRangeFilter').and_return(true)
      @filter.should_receive(:TxnDateRangeFilter).and_return(@txn_date_range_filter)
      
      @txn_date_range_filter.should_receive(:respond_to_ole?).with('ORTxnDateRangeFilter').and_return(true)
      @txn_date_range_filter.should_receive(:ORTxnDateRangeFilter).and_return(@or_date_range_filter)
      
      @or_date_range_filter.should_receive(:respond_to_ole?).with('TxnDateFilter').and_return(true)
      @or_date_range_filter.should_receive(:TxnDateFilter).and_return(@final_filter)
      
      @request.__send__(:filter_for, 'txn_date_range').should be(@final_filter)
    end
  end
  
  describe "#add_owner_ids" do
    before(:each) do
      @request = QBFC::Request.new(@sess, 'CustomerQuery')
      @owner_list = mock(QBFC::OLEWrapper)
    end
  
    it "can add a single owner id to the Request" do
      @ole_request.should_receive(:OwnerIDList).and_return(@owner_list)
      @owner_list.should_receive(:Add).with(0)
      @request.add_owner_ids(0)
    end

    it "can add multiple owner ids to the Request" do
      ids = ["{6B063959-81B0-4622-85D6-F548C8CCB517}", 0]
      @ole_request.should_receive(:OwnerIDList).twice.and_return(@owner_list)
      @owner_list.should_receive(:Add).with(ids[0])
      @owner_list.should_receive(:Add).with(ids[1])
      @request.add_owner_ids(ids)
    end

    it "can accept nil and will do nothing" do
      @ole_request.should_not_receive(:OwnerIDList)
      @owner_list.should_not_receive(:Add)
      @request.add_owner_ids(nil)
    end
  end
  
  describe "#add_limit" do
    before(:each) do
      @request = QBFC::Request.new(@sess, 'CustomerQuery')
      @filter = mock('Request#filter')
      @request.stub!(:filter).and_return(@filter)
    end
 
    it "can should update the filter's max_returned value" do
      @filter.should_receive(:max_returned=).with(1)
      @request.add_limit(1)
    end
  end
end
