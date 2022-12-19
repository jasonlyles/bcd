class AddFileToPartsLists < ActiveRecord::Migration
  def change
    add_column :parts_lists, :file, :string
  end
end
