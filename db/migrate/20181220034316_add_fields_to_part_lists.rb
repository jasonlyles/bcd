class AddFieldsToPartLists < ActiveRecord::Migration
  def change
    add_column :parts_lists, :approved, :boolean, default: false
    add_column :parts_lists, :parts, :json
    add_column :parts_lists, :url, :string
  end
end
