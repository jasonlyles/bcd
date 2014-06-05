class CreateAdvertisingCampaigns < ActiveRecord::Migration
  def self.up
    create_table :advertising_campaigns do |t|
      t.integer :partner_id
      t.string :reference_code, :limit => 10
      t.boolean :campaign_live, :default => false
      t.string :description

      t.timestamps
    end

    add_index :advertising_campaigns, :partner_id
  end

  def self.down
    drop_table :advertising_campaigns
  end
end
