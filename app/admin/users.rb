ActiveAdmin.register User do
  menu parent: 'Users'
  config.batch_actions = false
  actions :all, except: %i[destroy new]
  permit_params :account_status

  filter :email
  filter :account_status, as: :select, collection: -> { { active: 'A', guest: 'G', cancelled: 'C' } }
  filter :tos_accepted, as: :check_boxes
  filter :created_at
  filter :referrer_code
  filter :sign_in_count
  filter :email_preference, as: :select, collection: -> { { 'All Emails' => 2, 'Important Emails' => 1, 'No Emails' => 0 } }

  index do
    column 'Email' do |user|
      link_to user.email, admin_user_path(user.id)
    end
    tag_column :account_status, interactive: true
    bool_column :tos_accepted
    column 'Signed Up', &:created_at
    column :referrer_code
    column :sign_in_count
    tag_column :email_preference
    actions
  end

  show do
    tabs do
      tab 'General Info' do
        attributes_table do
          row 'Become the user' do |user|
            link_to "Become #{user.email}!", become_admin_path(user.id)
          end
          row :email
          row :account_status
          row :email_preference
          row 'Terms of Service Accepted', &:tos_accepted
          row 'GUID', &:guid
          row :referrer_code
          row 'Signed Up', &:created_at
          row 'Last Modified', &:updated_at
          row :sign_in_count
        end
      end
      tab 'Login/Password Info' do
        attributes_table title: 'Login/Password Details' do
          row :encrypted_password
          row :reset_password_token
          row :reset_password_sent_at
          row :remember_created_at
          row :current_sign_in_at
          row :current_sign_in_ip
          row :last_sign_in_at
          row :last_sign_in_ip
          row :failed_attempts
          row :locked_at
          row :unsubscribe_token
        end
        render 'authentications', authentications: user.authentications
      end
      tab 'Order Info' do
        render 'orders', orders: user.orders
      end
      tab 'Gift Instructions' do
        render 'gift_instructions', user: user, products: Product.ready_instructions.order('category_id').order('product_code')
      end
      tab 'Downloads' do
        render 'downloads', user: user, downloads: user.downloads
      end
    end
    br
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :account_status, as: :select, hint: 'This is really the only value we should be changing for users.'
    end
    f.actions
  end

  member_action :reset_downloads, method: :put do
    download = Download.find(params[:id])
    user_id = download.user_id
    download.reset!
    redirect_to admin_user_path(user_id), notice: 'Downloads reset'
  end
end
