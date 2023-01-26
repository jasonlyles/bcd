class DropSalesReports < ActiveRecord::Migration[7.0]
  def change
    drop_table :sales_reports
  end
end
