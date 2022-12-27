require 'resque/server'

Rails.application.routes.draw do
  mount_roboto

  # For PayPal to send to us, sits outside the admin namespace
  resources :instant_payment_notifications, only: %i[create]

  namespace :admin do
    resources :advertising_campaigns
    resources :backend_notifications, only: %i[index], path: 'notifications' do
      member do
        put :dismiss
      end
    end
    resources :categories do
      member do
        get :subcategories
      end
    end
    resources :colors
    resources :elements do
      collection do
        post :find_or_create
      end
    end
    resources :email_campaigns
    resources :images
    resources :instant_payment_notifications, only: %i[index show]
    resources :partners
    resources :parts do
      member do
        put :update_via_bricklink
        put :update_via_rebrickable
      end
    end
    resources :parts_lists do
      collection do
        get :part_swap
        post :create_new_elements
        post :swap_parts
        post :notify_customers_of_parts_list_update
      end
    end
    resources :product_types
    resources :products
    resources :subcategories do
      member do
        get :model_code
      end
    end
    resources :updates
  end

  if Rails.env.development?
    # MailPreview routes
    mount ContactMailer::Preview => 'contact_preview'
    mount UpdateMailer::Preview => 'update_preview'
    mount OrderMailer::Preview => 'order_preview'
    mount MarketingMailer::Preview => 'marketing_preview'
  end

  devise_for :radmins
  authenticate :radmin do
    mount Resque::Server.new, at: '/jobs', as: 'jobs'
    get '/jobs/bcd admin', to: redirect('/woofay') # Trick for adding a link back to BCD admin from Resque dashboard
  end

  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords' }
  devise_scope :user do
    get 'account/edit' => 'registrations#edit'
    get '/guest_registration' => 'sessions#guest_registration', as: :guest_registration
    post '/register_guest' => 'sessions#register_guest', as: :register_guest
    patch 'passwords/update_password', to: 'passwords#update_password'
  end

  get '/auth/:provider/callback' => 'authentications#create'
  get '/auth/failure' => 'authentications#failure'

  resources :authentications, only: %i[create destroy] do
    collection do
      post :clear_authentications, as: :clear
    end
  end

  # Admin routes
  resources :admin, path: :woofay do
    member do
      get :index
      get :become
      get :admin_profile
      patch :update_admin_profile
    end
  end

  resources :parts_lists, only: %i[show]
  resources :user_parts_lists, only: %i[update]

  # TODO: Some of these routes/actions probably belong in different controllers. Re-work them.
  get '/featured_products' => 'admin#featured_products'
  post '/gift_instructions' => 'admin#gift_instructions'
  post '/woofay/switch_maintenance_mode' => 'admin#switch_maintenance_mode'
  match '/woofay/:email/find_user' => 'admin#find_user', constraints: { email: /.*/ }, via: :post
  post '/woofay/find_order' => 'admin#find_order'
  get '/order_info' => 'admin#order_info', as: :order_info
  post '/woofay/:email/change_user_status' => 'admin#change_user_status', constraints: { email: /.*/ }
  post '/woofay/update_downloads_for_user', to: 'admin#update_downloads_for_user'
  post '/woofay/complete_order', to: 'admin#complete_order'
  get '/maintenance_mode', to: 'admin#maintenance_mode', as: :maintenance_mode
  get '/account_info' => 'admin#account_info', as: :account_info
  get '/new_product_notification' => 'admin#new_product_notification', as: :new_product_notification
  post '/send_new_product_notification' => 'admin#send_new_product_notification', as: :send_new_product_notification
  get 'update_users_download_counts' => 'admin#update_users_download_counts', as: :update_users_download_counts
  get 'order_fulfillment' => 'admin#order_fulfillment', as: :order_fulfillment
  patch 'update_order_shipping_status' => 'admin#update_order_shipping_status', as: :update_order_shipping_status
  get 'sales_report' => 'admin#sales_report', as: :sales_report
  post 'sales_report_monthly_stats' => 'admin#sales_report_monthly_stats', as: :sales_report_monthly_stats
  get '/order/:id', to: 'admin#order'
  get '/transactions_by_month', to: 'admin#transactions_by_month'

  post '/retire_product', to: 'admin/products#retire_product'
  patch '/send_marketing_emails' => 'admin/email_campaigns#send_marketing_emails'
  patch '/send_marketing_email_preview' => 'admin/email_campaigns#send_marketing_email_preview'

  # Static routes
  get 'books', to: 'static#books', constraints: { format: 'html' }
  get 'googlehostedservice', to: 'static#google_hosted_service', constraints: { format: 'html' }
  get 'maintenance', to: 'static#maintenance'
  get 'contact', to: 'static#contact'
  post 'send_contact_email', to: 'static#send_contact_email'
  get 'terms_of_service', to: 'static#terms_of_service'
  get 'privacy_policy', to: 'static#privacy_policy'
  get 'coppa_policy', to: 'static#coppa_policy'
  get 'faq', to: 'static#faq'
  get 'new_user_tutorial', to: 'static#new_user_tutorial'
  get 'exception_notification_test', to: 'static#test_exception_notification_delivery'

  # download routes
  get 'download/error', to: 'downloads#error'
  get 'download/:product_code', to: 'downloads#download'
  get 'download_parts_list/:parts_list_id', to: 'downloads#download_parts_list'
  get 'guest_download_parts_list/:parts_list_id/:order_id', to: 'downloads#guest_download_parts_list'
  get 'guest_download', to: 'downloads#guest_download'
  get 'guest_downloads', to: 'downloads#guest_downloads'
  get 'download_link_error', to: 'downloads#link_error'

  # account routes
  get 'account', to: 'account#index'
  get 'account/order_history', to: 'account#order_history'
  get 'account/order/:request_id', to: 'account#order'
  post 'order_issue', to: 'account#order_issue'
  get 'unsubscribe', to: 'account#unsubscribe_from_emails'

  # store routes
  get 'store/products/:product_type_name', to: 'store#products', action: 'store/products/:product_type_name', as: :store_products
  get 'store/products/:product_type_name/:category_name', to: 'store#categories', action: 'store/products/:product_type_name/:category_name', as: :store_categories
  get 'store/instructions', to: 'store#instructions'
  get 'store/kits', to: 'store#kits'
  get 'store/models', to: 'store#models'
  get 'thank_you', to: 'store#thank_you_for_your_order'
  get 'order_test', to: 'store#order_confirmation_email_test'
  get 'physical_order_test', to: 'store#physical_order_email_test'
  get 'store', to: 'store#index'
  post 'add_to_cart/:product_code', to: 'store#add_to_cart'
  get 'add_to_cart/:product_code', to: 'store#add_to_cart'
  get 'cart', to: 'store#cart'
  post 'empty_cart', to: 'store#empty_cart'
  post 'remove_item_from_cart/:id', to: 'store#remove_item_from_cart'
  post 'update_item_in_cart', to: 'store#update_item_in_cart'
  get 'checkout', to: 'store#checkout'
  get 'enter_address', to: 'store#enter_address'
  post 'save_order', to: 'store#save_order'
  post 'submit_order', to: 'store#submit_order'
  post 'validate_street_address', to: 'store#validate_street_address'

  # misc routes
  get '/campaign/:guid' => 'email_campaigns#register_click_through_and_redirect'

  get ':product_code/:product_name', to: 'store#product_details'

  root to: 'static#index'
end
