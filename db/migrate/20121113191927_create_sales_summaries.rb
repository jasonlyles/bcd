class CreateSalesSummaries < ActiveRecord::Migration
  def up
    create_table :sales_summaries do |t|
      t.integer :sales_report_id
      t.integer :product_id
      t.integer :quantity
      t.decimal :total_revenue

      t.timestamps
    end
  end

  def down
    drop_table :sales_summaries
  end
end
