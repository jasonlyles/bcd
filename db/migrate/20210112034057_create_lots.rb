class CreateLots < ActiveRecord::Migration[4.2]
  def change
    create_table :lots do |t|
      t.references :parts_list
      t.references :element
      t.integer :quantity

      t.timestamps

      t.index :parts_list_id
      t.index :element_id
      t.index %i[parts_list_id element_id], unique: true
    end
  end
end
