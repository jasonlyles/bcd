class ChangeOrderStatusLength < ActiveRecord::Migration[7.0]
  def up
    change_column :orders, :status, :string, limit: 30
  end

  def down
    change_column :orders, :status, :string, limit: 10
  end
end
