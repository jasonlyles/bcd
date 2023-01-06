class AddNoteToLots < ActiveRecord::Migration[4.2]
  def change
    add_column :lots, :note, :string, default: ''
  end
end
