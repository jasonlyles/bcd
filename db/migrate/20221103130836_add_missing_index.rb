class AddMissingIndex < ActiveRecord::Migration
  def change
    add_index :instant_payment_notifications, :order_id
  end
end
