class AddLotsCountToPartsList < ActiveRecord::Migration[7.1]
  def change
    add_column :parts_lists, :lots_count, :integer, default: 0, null: false
  end
end
