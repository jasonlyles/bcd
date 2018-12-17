ActiveAdmin.register Partner do
  config.batch_actions = false
  menu parent: 'Marketing', priority: 0
  permit_params :name, :url, :contact

  filter :name
  filter :url
  filter :contact

  index do
    column 'Name' do |partner|
      link_to partner.name, admin_partner_path(partner.id)
    end
    column :url
    column :contact
    actions
  end

  show do
    attributes_table do
      row :name
      row 'URL' do |partner|
        link_to partner.url, partner.url, target: '_blank'
      end
      row :contact
    end
    render 'admin/partners/advertising_campaigns', advertising_campaigns: partner.advertising_campaigns
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name
      f.input :url
      f.input :contact
    end
    f.actions
  end
end
