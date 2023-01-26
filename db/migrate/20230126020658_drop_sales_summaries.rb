class DropSalesSummaries < ActiveRecord::Migration[7.0]
  def change
    drop_table :sales_summaries
  end
end
