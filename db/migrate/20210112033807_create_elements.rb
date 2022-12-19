class CreateElements < ActiveRecord::Migration
  def change
    create_table :elements do |t|
      t.references  :part
      t.references  :color
      t.string      :image
      t.string      :original_image_url
      t.string      :guid, limit: 36
      t.boolean     :image_processing, default: false

      t.timestamps

      t.index :part_id
      t.index :color_id
      t.index [:part_id, :color_id], unique: true
    end
  end
end
