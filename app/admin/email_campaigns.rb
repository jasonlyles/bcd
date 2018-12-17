ActiveAdmin.register EmailCampaign do
  config.batch_actions = false
  menu parent: 'Marketing', priority: 2
  permit_params :description, :message, :subject, :image, :image_cache, :redirect_link

  filter :description
  filter :redirect_link
  filter :guid, label: 'Reference ID'

  index do
    column 'Description' do |campaign|
      link_to snippet(campaign.description, word_count: 10), admin_email_campaign_path(campaign.id)
    end
    column 'Reference ID', &:guid
    column :redirect_link
    column :emails_sent
    column :effectiveness_ratio
    actions
  end

  show do
    attributes_table do
      row :description
      row :subject
      row :message
      row 'Reference ID', &:guid
      row 'Redirect Link' do |campaign|
        link_to campaign.redirect_link, campaign.redirect_link
      end
      row 'Image' do |campaign|
        image_tag(campaign.image, class: 'medium') if campaign.image?
      end
      row :emails_sent
      row :click_throughs
      row :effectiveness_ratio
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :description
      f.input :subject
      f.input :message
      f.input :redirect_link
      if email_campaign.image?
        render 'admin/shared/images', model: email_campaign
        f.input :remove_image, as: :boolean, label: 'Delete Image'
      else
        f.input :image, as: :file
      end
      f.input :image_cache, as: :hidden
    end
    f.actions
  end
end
