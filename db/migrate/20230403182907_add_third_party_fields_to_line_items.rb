class AddThirdPartyFieldsToLineItems < ActiveRecord::Migration[7.0]
  def change
    add_column :line_items, :third_party_line_item_identifier, :string
    add_column :line_items, :third_party_line_item_paid_at, :datetime
  end
end
