class CreateDownloads < ActiveRecord::Migration
  def self.up
    create_table :downloads do |t|
      t.integer :product_id
      t.integer :count, :default => 0
      t.integer :user_id
      t.integer :remaining, :default => MAX_DOWNLOADS
      t.string :download_token

      t.timestamps
    end
  end

  def self.down
    drop_table :downloads
  end
end
