require 'spec_helper'

describe Admin::SalesReportsController do
  before do
    @radmin ||= FactoryBot.create(:radmin)
  end

  before(:each) do |example|
    sign_in @radmin unless example.metadata[:skip_before]
  end

  describe 'new' do
    it 'should render the sales report page' do
      sign_in @radmin
      get :new

      expect(response).to render_template('new')
    end
  end

  describe 'create' do
    it 'should return a hash of stat summaries for a single month report when the report has been completed' do
      FactoryBot.create(:product_with_associations)
      FactoryBot.create(:order_with_line_items)
      @sales_report = SalesReport.new(Time.now.utc.to_date.month, Time.now.utc.to_date.year)
      post :create, params: { report: { 'month' => Time.now.utc.to_date.month, 'year' => Time.now.utc.to_date.year } }, format: :js

      expect(assigns(:summaries)).to eq({ '1' => { 'qty' => 1, 'revenue' => BigDecimal('10') } })
    end
  end

  describe 'transactions_by_month' do
    it 'should return all transactions for a given month' do
      FactoryBot.create(:user)
      FactoryBot.create(:product_with_associations)
      FactoryBot.create(:order_with_line_items)
      get :transactions_by_month, params: { date: Time.now.utc.to_date.strftime('%Y-%m-%d') }, format: 'csv'

      expect(assigns(:transactions).size).to eq(1)
    end
  end
end
