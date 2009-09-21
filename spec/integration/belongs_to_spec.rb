require 'spec_helper'

# This spec describes "belong to" style relationships,
# that is where QuickBooks specifies a Ref to another object.

describe "belongs to: " do

  before(:each) do 
    @integration = QBFC::Integration::reader
    @sess = @integration.session
  end
  
  after(:each) do 
    @integration.close
  end
  
  describe "Bob Customer" do
    before(:each) do
      @customer = @sess.customers.find("Bob Customer")
    end
  
    it "has terms" do
      @customer.terms.should be_kind_of(QBFC::Terms)
      @customer.terms.id.should == @sess.terms.find("Net 30").id
    end
    
    it "should not have a sales rep" do
      @customer.sales_rep.should be_nil
    end
  end
  
  describe "Check to ABC Supplies" do
    before(:each) do
      @check = @sess.checks.find_by_ref("1000")
    end
  
    it "has a payee" do
      @check.payee.should be_kind_of(QBFC::Vendor)
      @check.payee.id.should == @sess.vendors.find("ABC Supplies").id
    end
    
    it "has an account" do
      @check.account.should be_kind_of(QBFC::Account)
      @check.account.id.should == @sess.accounts.find("Checking").id
    end
  end
  
  describe "Invoice to Customer Bob" do
    before(:each) do
      @invoice = @sess.invoices.find_by_ref("1")
    end
  
    it "has a template" do
      @invoice.template.should be_kind_of(QBFC::Template)
      @invoice.template.id.should == @sess.templates.find("Intuit Service Invoice").id
    end
    
    it "has a Customer" do
      @invoice.customer.should be_kind_of(QBFC::Customer)
      @invoice.customer.id.should == @sess.customers.find("Bob Customer").id
    end
  end
  
end