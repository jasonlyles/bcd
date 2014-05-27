class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :user_id
      t.string :transaction_id, :limit => 50
      t.string :request_id, :limit => 50
      t.string :status, :limit => 10
      t.string :address_state, :default => nil
      t.string :address_street_1, :default => nil
      t.string :address_street_2, :default => nil
      t.string :address_country, :default => nil
      t.string :address_zip, :default => nil
      t.string :address_city, :default => nil
      t.string :address_name, :default => nil
      t.string :first_name, :default => nil
      t.string :last_name, :default => nil
      t.integer :shipping_status

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end