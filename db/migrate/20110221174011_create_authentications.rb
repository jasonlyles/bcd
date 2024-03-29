class CreateAuthentications < ActiveRecord::Migration[4.2]
  def self.up
    create_table :authentications do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.timestamps
    end

    add_index :authentications, :user_id
  end

  def self.down
    drop_table :authentications
  end
end
