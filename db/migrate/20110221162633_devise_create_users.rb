class DeviseCreateUsers < ActiveRecord::Migration[4.2]
  def self.up
    create_table(:users) do |t|
      ## Database authenticatable
      t.string :email, null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer :sign_in_count, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip
      t.integer :email_preference, default: 1
      t.string :account_status, limit: 1, default: 'A'
      t.string :referrer_code, limit: 10

      ## Lockable
      t.integer  :failed_attempts, default: 0
      t.datetime :locked_at

      t.boolean :tos_accepted, default: false
      t.string :guid
      t.string :unsubscribe_token

      t.timestamps
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
  end

  def self.down
    drop_table :users
  end
end
