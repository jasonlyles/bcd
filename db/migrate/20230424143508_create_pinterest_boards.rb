class CreatePinterestBoards < ActiveRecord::Migration[7.0]
  def change
    create_table :pinterest_boards do |t|
      t.string :topic, null: false, unique: true
      t.string :pinterest_native_id, null: false, unique: true

      t.timestamps
    end
  end
end
