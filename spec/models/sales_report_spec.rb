require 'spec_helper'

describe SalesReport do
  before do
    @product = FactoryBot.create(:product_with_associations)
  end

  describe 'single_month_display' do
    it 'should return the full month name and year for a single month' do
      sales_report = SalesReport.new('11', '2012')

      expect(sales_report.single_month_display).to eq('November 2012')
    end
  end

  describe 'generate_sales_report' do
    it 'should return a hash with product ID, quantity and revenue for each product sold during the month' do
      FactoryBot.create(:order_with_line_items)
      sr = SalesReport.new(Date.today.month, Date.today.year)
      summary = sr.generate_sales_report

      expect(summary).to eq({ '1' => { 'qty' => 1, 'revenue' => BigDecimal('10.0') } })
    end

    it 'should return quantities and revenue based on all orders for the report month' do
      FactoryBot.create(:order_with_line_items)
      FactoryBot.create(:order_with_line_items)
      sr = SalesReport.new(Date.today.month, Date.today.year)
      summary = sr.generate_sales_report

      expect(summary).to eq({ '1' => { 'qty' => 2, 'revenue' => BigDecimal('20.0') } })
    end

    it 'should return nil if no orders can be found for the report month' do
      sr = SalesReport.new(Date.today.month, Date.today.year)
      summary = sr.generate_sales_report

      expect(summary).to be_nil
    end
  end
end
