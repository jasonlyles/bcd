class CreateCategories < ActiveRecord::Migration[4.2]
  def self.up
    create_table :categories do |t|
      t.string :name
      t.text :description
      t.boolean :ready_for_public, default: false
      t.string :image

      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end
end
