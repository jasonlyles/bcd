class CreateThirdPartyReceipt < ActiveRecord::Migration[7.0]
  def change
    create_table :third_party_receipts do |t|
      t.references :order, null: false
      t.integer :source, null: false, index: true
      t.string :third_party_receipt_identifier, null: false, index: true
      t.string :third_party_order_status, null: false, index: true
      t.boolean :third_party_is_paid, index: true
      t.datetime :third_party_created_at
      t.datetime :third_party_updated_at
      t.text :raw_response_body, null: false

      t.timestamps
    end
  end
end
