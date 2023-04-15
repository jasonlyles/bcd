class AddSourceFieldsToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :source, :integer, default: 0, index: true
    add_column :orders, :third_party_order_identifier, :string, index: true
  end
end
