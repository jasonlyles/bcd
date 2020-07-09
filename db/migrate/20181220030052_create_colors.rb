class CreateColors < ActiveRecord::Migration
  def change
    create_table :colors do |t|
      t.integer :bl_id, limit: 2
      t.integer :ldraw_id, limit: 2, unique: true
      t.integer :lego_id, limit: 2
      t.string  :name, limit: 50
      t.string  :bl_name, limit: 50
      t.string  :lego_name, limit: 50
      t.string  :ldraw_rgb, limit: 6
      t.string  :rgb, limit: 6

      t.timestamps
    end
  end
end
