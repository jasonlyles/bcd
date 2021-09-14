class AddFieldsToPartsLists < ActiveRecord::Migration
  def change
    add_column :parts_lists, :approved, :boolean, default: false
    add_column :parts_lists, :parts, :json
    add_column :parts_lists, :bricklink_xml, :text
    add_column :parts_lists, :ldr, :text
  end
end
