class AddEtsyFieldsToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :etsy_listing_id, :string
    add_column :products, :etsy_listing_file_id, :string
    add_column :products, :etsy_listing_state, :string
    add_column :products, :etsy_listing_url, :string
    add_column :products, :etsy_created_at, :datetime, precision: nil
    add_column :products, :etsy_updated_at, :datetime, precision: nil
  end
end
