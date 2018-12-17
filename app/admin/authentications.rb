ActiveAdmin.register Authentication do
  menu parent: 'Users'
  config.clear_action_items!
  config.batch_actions = false

  filter :provider, as: :select, collection: -> { %w[twitter facebook] }
  filter :uid
  filter :created_at
  filter :updated_at

  index do
    column 'ID' do |authentication|
      link_to authentication.id, admin_authentication_path(authentication.id)
    end
    column 'User' do |authentication|
      link_to authentication.user.email, admin_user_path(authentication.user_id)
    end
    column :provider
    column :uid
    column :created_at
    column :updated_at

    actions defaults: false do |auth|
      link_to t('active_admin.view'), admin_authentication_path(auth)
    end
  end
end
