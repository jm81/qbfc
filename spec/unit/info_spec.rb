require 'spec_helper'

module QBFC::Test
  class Info < QBFC::Info
    def self.qb_name
      "Company"
    end
  end
end

describe QBFC::Info do

 before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
    @info = mock(QBFC::Test::Info)
    
    # Request related mocks
    @request = mock("QBFC::Request")
    @response = mock("QBFC::Request#response")
    
    QBFC::Request.stub!(:new).with(@sess, 'CompanyQuery').and_return(@request)
    @request.stub!(:response).and_return(@response)
    QBFC::Test::Info.stub!(:new).with(@sess, @response).and_return(@info)
    @request.stub!(:apply_options)
  end
  
  describe ".get" do
    it "should create Request and get response" do
      QBFC::Request.should_receive(:new).with(@sess, 'CompanyQuery').and_return(@request)
      @request.should_receive(:response).and_return(@response)
      QBFC::Test::Info.should_receive(:new).with(@sess, @response).and_return(@info)
      QBFC::Test::Info::get(@sess)
    end
    
    it "applies options to Request" do
      @request.should_receive(:apply_options).with({:owner_id => 0})
      QBFC::Test::Info::get(@sess, :owner_id => 0)
    end
  end
  
  describe ".find" do
    it "should forward request, without 'what' argument, to get" do
      QBFC::Test::Info.should_receive(:get).with(@sess, {})
      QBFC::Test::Info::find(@sess, :first, {})
    end
  end
end