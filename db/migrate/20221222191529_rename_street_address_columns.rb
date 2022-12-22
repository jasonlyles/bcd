class RenameStreetAddressColumns < ActiveRecord::Migration[5.0]
  def change
    rename_column :orders, :address_street_1, :address_street1
    rename_column :orders, :address_street_2, :address_street2
  end
end
