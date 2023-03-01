class AddSourceToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :source, :integer, default: 0
  end
end
