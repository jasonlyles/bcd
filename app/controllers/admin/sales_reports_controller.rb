# frozen_string_literal: true

class Admin::SalesReportsController < AdminController
  def new; end

  def create
    @report = SalesReport.new(params[:report][:month], params[:report][:year])
    @summaries = @report.generate_sales_report

    respond_to(&:js)
  end

  # CSV download link goes here
  def transactions_by_month
    date = Date.parse(params[:date])
    @transactions = Order.all_transactions_for_month(date.month, date.year)
    respond_to do |format|
      format.html
      format.csv { send_data Order.transaction_csv(@transactions), { filename: "#{date.strftime('%Y')}_#{date.strftime('%m')}_transactional_detail.csv" } }
    end
  end
end
