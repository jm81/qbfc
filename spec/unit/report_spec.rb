require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QBFC::Report do

  describe ".get_class" do
    it "should get the class for this report" do
      QBFC::Report.get_class("AuditTrail").should be(QBFC::Reports::GeneralDetail)
      QBFC::Report.get_class("PayrollSummary").should be(QBFC::Reports::PayrollSummary)
      QBFC::Report.get_class("TimeByJobDetail").should be(QBFC::Reports::Time)
    end
  end
end