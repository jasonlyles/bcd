class CreateUpdates < ActiveRecord::Migration[4.2]
  def self.up
    create_table :updates do |t|
      t.string :title
      t.string :description
      t.text :body
      t.string :image_align
      t.string :image
      t.boolean :live, default: false
      t.string :link

      t.timestamps
    end
  end

  def self.down
    drop_table :updates
  end
end
