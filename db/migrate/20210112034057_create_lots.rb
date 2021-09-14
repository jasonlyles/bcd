class CreateLots < ActiveRecord::Migration
  def change
    create_table :lots do |t|
      t.references :parts_list
      t.references :element
      t.integer :quantity

      t.timestamps

      t.index :parts_list_id
      t.index :element_id
      t.index [:parts_list_id, :element_id], unique: true
    end
  end
end
