class AddJidToPartsLists < ActiveRecord::Migration[7.0]
  def change
    add_column :parts_lists, :jid, :string, default: nil
  end
end
