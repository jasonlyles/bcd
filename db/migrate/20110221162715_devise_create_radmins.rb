class DeviseCreateRadmins < ActiveRecord::Migration[4.2]
  def self.up
    create_table(:radmins) do |t|
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

      ## Lockable
      t.integer :failed_attempts, default: 0
      t.datetime :locked_at

      t.timestamps
    end

    add_index :radmins, :email,                unique: true
    add_index :radmins, :reset_password_token, unique: true
  end

  def self.down
    drop_table :radmins
  end
end
