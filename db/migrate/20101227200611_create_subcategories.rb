class CreateSubcategories < ActiveRecord::Migration[4.2]
  def self.up
    create_table :subcategories do |t|
      t.string :name
      t.text :description
      t.integer :category_id
      t.string :code
      t.boolean :ready_for_public, default: false

      t.timestamps
    end

    add_index :subcategories, :category_id
  end

  def self.down
    drop_table :subcategories
  end
end
