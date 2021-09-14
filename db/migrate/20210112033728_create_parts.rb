class CreateParts < ActiveRecord::Migration
  def change
    create_table :parts do |t|
      t.string  :bl_id, limit: 20
      t.string  :ldraw_id, limit: 20, unique: true
      t.string  :lego_id, limit: 20
      t.string  :name
      t.boolean :check_bricklink, default: true
      t.boolean :check_rebrickable, default: true
      t.json    :alternate_nos
      t.boolean :is_obsolete, default: false
      t.string  :year_from, limit: 4
      t.string  :year_to, limit: 4
      t.json    :brickowl_ids
      t.boolean :is_lsynth, default: false

      t.timestamps
    end
  end
end
