class CreatePartsLists < ActiveRecord::Migration
  def change
    create_table :parts_lists do |t|
      t.string :parts_list_type
      t.string :name
      t.integer :product_id

      t.timestamps
    end

    add_index :parts_lists, :product_id
  end
end
