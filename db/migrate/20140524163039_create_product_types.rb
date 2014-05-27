class CreateProductTypes < ActiveRecord::Migration
  def self.up
    create_table :product_types do |t|
      t.string :name
      t.text :description
      t.string :image
      t.boolean :ready_for_public, :default => false
      t.text :comes_with_description
      t.string :comes_with_title
      t.boolean :digital_product, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table(:product_types)
  end
end
