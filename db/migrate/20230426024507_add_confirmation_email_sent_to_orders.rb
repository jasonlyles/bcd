class AddConfirmationEmailSentToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :confirmation_email_sent, :boolean, default: false
  end
end
