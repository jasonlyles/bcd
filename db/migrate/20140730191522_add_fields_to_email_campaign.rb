class AddFieldsToEmailCampaign < ActiveRecord::Migration[4.2]
  def change
    add_column :email_campaigns, :image_processing, :boolean, default: false
    add_column :email_campaigns, :message, :text
    add_column :email_campaigns, :subject, :string
    add_column :email_campaigns, :emails_sent, :integer, default: 0
    add_column :email_campaigns, :guid, :string
    add_column :email_campaigns, :image, :string
    add_column :email_campaigns, :redirect_link, :string
    change_column_default(:email_campaigns, :click_throughs, 0)
  end
end
