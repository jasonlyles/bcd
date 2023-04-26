class CreatePinterestPins < ActiveRecord::Migration[7.0]
  def change
    create_table :pinterest_pins do |t|
      t.references :pinterest_board, null: false
      t.references :product, null: false
      t.references :image, null: false
      t.string :pinterest_native_id, null: false
      t.string :link, null: false
      t.string :title, null: false
      t.text :description, null: false

      t.timestamps
    end
  end
end
