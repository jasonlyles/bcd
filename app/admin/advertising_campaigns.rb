ActiveAdmin.register AdvertisingCampaign do
  config.batch_actions = false
  menu parent: 'Marketing', priority: 1
  permit_params :partner_id, :reference_code, :campaign_live, :description

  filter :partner
  filter :reference_code
  filter :campaign_live

  index do
    column 'Reference Code' do |campaign|
      link_to campaign.reference_code, admin_advertising_campaign_path(campaign.id)
    end
    column :partner
    column 'Live?', &:campaign_live
    column 'Description' do |campaign|
      snippet(campaign.description, word_count: 10)
    end
    actions
  end

  show do
    attributes_table do
      row :partner
      row :reference_code
      row :description
      row 'Live?', &:campaign_live
    end
    active_admin_comments
  end

  form do |f|
    br
    div class: 'nice-padding' do
      text_node('Note: The url we give the partner to feed to us for this advertising campaign would look like this: https://brickcitydepot.com?referrer_code=12345ABCDE, where 12345ABCDE is the reference code you set below.')
    end
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :partner
      f.input :reference_code, hint: 'Must be exactly 10 characters'
      f.input :description, hint: 'Description (This is just for us, some notes on what makes this campaign different, how much it cost, how long it was, etc.)'
      f.input :campaign_live, label: 'Campaign Live?'
    end
    f.actions
  end
end
