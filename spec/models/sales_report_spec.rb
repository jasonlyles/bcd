require 'spec_helper'

describe SalesReport do
  describe "multiple_months?" do
    it "should return false if end_date is blank" do
      @sales_report = FactoryGirl.create(:sales_report, :report_date => '2012-11-01')

      expect(@sales_report.multiple_months?).to eq(false)
    end

    it "should return true if end date is not blank and end_date is in the sometime in the future relative to the start date" do
      @sales_report = FactoryGirl.create(:sales_report, :report_date => '2012-11-01')
      @sales_report.end_date = {'month' => 01, 'year' => 2013}

      expect(@sales_report.multiple_months?).to eq(true)
    end

    it "should return false if end date is not in the right chronological order" do
      @sales_report = FactoryGirl.create(:sales_report, :report_date => '2012-11-01')
      @sales_report.end_date = {'month' => 01, 'year' => 2012}

      expect(@sales_report.multiple_months?).to eq(false)
    end

    it "should return false if end_date is the same as the start_date" do
      @sales_report = FactoryGirl.create(:sales_report, :report_date => '2012-11-01')
      @sales_report.end_date = {'month' => 11, 'year' => 2012}

      expect(@sales_report.multiple_months?).to eq(false)
    end
  end

  describe "single_month_display" do
    it "should return the full month name and year for a single month" do
      @sales_report = FactoryGirl.create(:sales_report, :report_date => '2012-11-01')

      expect(@sales_report.single_month_display).to eq('November 2012')
    end
  end

  describe "multiple_months_display" do
    it "should return abbreviated month names and the years for both start and end dates" do
      @sales_report = FactoryGirl.create(:sales_report, :report_date => '2012-11-01')
      @sales_report.end_date = {'month' => 01, 'year' => 2013}

      expect(@sales_report.multiple_months_display).to eq('Nov 2012 - Jan 2013')
    end
  end
  describe "generate_sales_report" do
    it "should save sales_summaries for each product sold during the report month" do
      @order = FactoryGirl.create(:order_with_line_items)
      sr = SalesReport.new(:report_date => Date.today)

      expect(lambda{sr.generate_sales_report}).to change(SalesSummary, :count).from(0).to(1)
    end

    it "should return a hash with product ID, quantity and revenue for each product sold during the month" do
      @order = FactoryGirl.create(:order_with_line_items)
      sr = SalesReport.new(:report_date => Date.today)
      summary = sr.generate_sales_report

      expect(summary).to eq({"1"=>{"qty"=>1, "revenue"=>BigDecimal('10.0')}})
    end

    it "should return quantities and revenue based on all orders for the report month" do
      @order = FactoryGirl.create(:order_with_line_items)
      @order2 = FactoryGirl.create(:order_with_line_items)
      sr = SalesReport.new(:report_date => Date.today)
      summary = sr.generate_sales_report

      expect(summary).to eq({"1"=>{"qty"=>2, "revenue"=>BigDecimal('20.0')}})
    end

    it "should return nil if no orders can be found for the report month" do
      sr = SalesReport.new(:report_date => Date.today)
      summary = sr.generate_sales_report

      expect(summary).to be_nil
    end
  end

  describe 'get_sweet_stats' do
    it "should get a sales report for a single month if only 1 month is selected" do
      @sales_report = FactoryGirl.create(:sales_report, :report_date => "#{Date.today.year}-#{Date.today.month}-01")
      @sales_report2 = FactoryGirl.create(:sales_report, :report_date => "2011-10-01")
      @sales_summary = FactoryGirl.create(:sales_summary, :sales_report_id => @sales_report.id, :product_id => 1) #current month
      @sales_summary2 = FactoryGirl.create(:sales_summary, :sales_report_id => @sales_report2.id, :product_id => 1) #previous month
      report = SalesReport.get_sweet_stats(Date.today.month,Date.today.year,nil,nil)

      expect(report).to eq({"1"=>{"qty"=>1, "revenue"=>BigDecimal('10')}})
    end

    it "should get sales reports for multiple months if multiple months are selected" do
      @sales_report = FactoryGirl.create(:sales_report, :report_date => "#{Date.today.year}-#{Date.today.month}-01")
      @sales_report2 = FactoryGirl.create(:sales_report, :report_date => "#{Date.today.next_month.strftime("%Y-%m-01")}")
      @sales_summary = FactoryGirl.create(:sales_summary, :sales_report_id => @sales_report.id, :product_id => 1) #current month
      @sales_summary2 = FactoryGirl.create(:sales_summary, :sales_report_id => @sales_report2.id, :product_id => 1) #previous month
      report = SalesReport.get_sweet_stats(Date.today.month,Date.today.year,Date.today.next_month.month,Date.today.next_month.year)

      expect(report).to eq({"1"=>{"qty"=>2, "revenue"=>BigDecimal('20')}})
    end
  end
end
