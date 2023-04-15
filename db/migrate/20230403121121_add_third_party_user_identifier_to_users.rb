class AddThirdPartyUserIdentifierToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :third_party_user_identifier, :string, index: true
  end
end
