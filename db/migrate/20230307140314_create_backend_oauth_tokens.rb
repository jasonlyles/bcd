class CreateBackendOauthTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :backend_oauth_tokens do |t|
      t.integer :provider
      t.string :access_token
      t.string :refresh_token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
