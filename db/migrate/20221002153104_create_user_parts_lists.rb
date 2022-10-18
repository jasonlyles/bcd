class CreateUserPartsLists < ActiveRecord::Migration
  def change
    create_table :user_parts_lists do |t|
      t.references :parts_list
      t.references :user
      t.text :values

      t.timestamps

      t.index :parts_list_id
      t.index :user_id
      t.index [:parts_list_id, :user_id], unique: true
    end
  end
end
