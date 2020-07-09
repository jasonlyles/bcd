class AddSpritesheetRelatedColumns < ActiveRecord::Migration
  def up
    add_column :parts_lists, :spritesheet_css, :string
    rename_column :parts_lists, :url, :spritesheet_image
  end

  def down
    remove_column :parts_lists, :spritesheet_css
    rename_column :parts_lists, :spritesheet_image, :url
  end
end
