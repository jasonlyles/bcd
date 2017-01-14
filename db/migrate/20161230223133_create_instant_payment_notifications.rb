class CreateInstantPaymentNotifications < ActiveRecord::Migration
  def change
    create_table :instant_payment_notifications do |t|
      t.string :payment_status
      t.string :notify_version
      t.string :request_id
      t.string :verify_sign
      t.string :payer_email
      t.string :txn_id
      t.json :params
      t.integer :order_id
      t.boolean :processed, default: false

      t.timestamps null: false
    end
  end
end
