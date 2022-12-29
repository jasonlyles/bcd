class AddFileToPartsLists < ActiveRecord::Migration[4.2]
  def change
    add_column :parts_lists, :file, :string
  end
end
