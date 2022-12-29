class AddMissingIndex < ActiveRecord::Migration[4.2]
  def change
    add_index :instant_payment_notifications, :order_id
  end
end
