class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.string :url
      t.integer :product_id
      t.integer :category_id
      t.string :location

      t.timestamps
    end

    add_index :images, :product_id
    add_index :images, :category_id
  end

  def self.down
    drop_table :images
  end
end
