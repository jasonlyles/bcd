class CreateSalesSummaries < ActiveRecord::Migration[4.2]
  def up
    create_table :sales_summaries do |t|
      t.integer :sales_report_id
      t.integer :product_id
      t.integer :quantity
      t.decimal :total_revenue

      t.timestamps
    end

    add_index :sales_summaries, :sales_report_id
    add_index :sales_summaries, :product_id
  end

  def down
    drop_table :sales_summaries
  end
end
