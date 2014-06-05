class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :name
      t.integer :product_type_id
      t.integer :category_id
      t.integer :subcategory_id
      t.string :product_code
      t.text :description
      t.decimal :discount_percentage, :default => 0
      t.decimal :price
      t.boolean :ready_for_public, :default => false
      t.string :pdf
      t.string :tweet
      t.boolean :free, :default => false
      t.integer :quantity, :default => 1
      t.boolean :alternative_build, :default => false
      t.string :youtube_url

      t.timestamps
    end

    add_index :products, :product_type_id
    add_index :products, :category_id
    add_index :products, :subcategory_id
  end

  def self.down
    drop_table :products
  end
end
