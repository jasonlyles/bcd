class CreateEmailCampaigns < ActiveRecord::Migration[4.2]
  def self.up
    create_table :email_campaigns do |t|
      t.text :description
      t.integer :click_throughs

      t.timestamps
    end
  end

  def self.down
    drop_table :email_campaigns
  end
end
