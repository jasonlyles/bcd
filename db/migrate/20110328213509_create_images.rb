class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.string :url
      t.integer :product_id
      t.integer :category_id
      t.string :location

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
