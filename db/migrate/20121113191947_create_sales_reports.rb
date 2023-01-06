class CreateSalesReports < ActiveRecord::Migration[4.2]
  def up
    create_table :sales_reports do |t|
      t.date :report_date
      t.boolean :completed, default: false

      t.timestamps
    end
  end

  def down
    drop_table :sales_reports
  end
end
