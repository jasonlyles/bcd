class AddProcessingFieldsToPartsLists < ActiveRecord::Migration
  def change
    add_column :parts_lists, :bricklink_xml, :text
    add_column :parts_lists, :ldr, :text
  end
end
