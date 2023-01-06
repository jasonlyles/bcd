class CreateLineItems < ActiveRecord::Migration[4.2]
  def self.up
    create_table :line_items do |t|
      t.integer :order_id
      t.integer :product_id
      t.integer :quantity
      t.decimal :total_price

      t.timestamps
    end

    add_index :line_items, :order_id
    add_index :line_items, :product_id
  end

  def self.down
    drop_table :line_items
  end
end
