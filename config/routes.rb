require 'resque/server'

BrickCity::Application.routes.draw do

  mount_roboto
  #Legacy routes
  get "for-sale", :to => "static#legacy_instructions", :constraints => {:format => 'html'}
  get "instructions", :to => "static#legacy_instructions", :constraints => {:format => 'html'}
  get "gallery", :to => "static#legacy_gallery", :constraints => {:format => 'html'}
  get "contact-us", :to => "static#legacy_contact", :constraints => {:format => 'html'}
  get "city-building-instructions", :to => "static#legacy_city_category", :constraints => {:format => 'html'}
  get "city-vehicles-instructions", :to => "static#legacy_city_category", :constraints => {:format => 'html'}
  get "city-vehicles", :to => "static#legacy_city_category", :constraints => {:format => 'html'}
  get "modular-buildings", :to => "static#legacy_city_category", :constraints => {:format => 'html'}
  get "winter-village-instructions", :to => "static#legacy_winter_village_category", :constraints => {:format => 'html'}
  get "train-instructions", :to => "static#legacy_train_category", :constraints => {:format => 'html'}
  get "wwii-instructions", :to => "static#legacy_military_category", :constraints => {:format => 'html'}
  get "wwii-models", :to => "static#legacy_military_category", :constraints => {:format => 'html'}
  get "castle-instructions", :to => "static#legacy_castle_category", :constraints => {:format => 'html'}
  get "commissions", :to => "static#legacy_commissions", :constraints => {:format => 'html'}
  get "googlehostedservice", :to => "static#legacy_google_hosted_service", :constraints => {:format => 'html'}
  get "lego_neighborhood_extras", :to => "static#legacy_lego_neighborhood_extras", :constraints => {:format => 'html'}
  get "sales-deals", :to => "static#legacy_sales_deals", :constraints => {:format => 'html'}
  get "store/p97/Star_Wars_Theme_Sign", :to => "static#legacy_star_wars_theme_sign", :constraints => {:format => 'html'}
  get "store/p96/Friends_Theme_Sign", :to => "static#legacy_friends_theme_sign", :constraints => {:format => 'html'}
  get "store/p95/City_Theme_Sign", :to => "static#legacy_city_theme_sign", :constraints => {:format => 'html'}
  get "store/p94/Logo_Theme_Sign", :to => "static#legacy_logo_theme_sign", :constraints => {:format => 'html'}
  get "store/p98/Club_23_Speakeasy_-_Instructions", :to => "static#legacy_speakeasy_instructions", :constraints => {:format => 'html'}
  get "store/p93/Architecture_Firm__-_Instructions", :to => "static#legacy_archfirm_instructions", :constraints => {:format => 'html'}
  get "store/p79/Menswear_Shop_Instructions", :to => "static#legacy_menswear_instructions", :constraints => {:format => 'html'}
  get "instruction_sample", :to => "static#legacy_instruction_sample", :constraints => {:format => 'html'}
  get "books", :to => "static#legacy_books", :constraints => {:format => 'html'}
  get "lego_prints", :to => "static#legacy_lego_prints", :constraints => {:format => 'html'}
  get "custom-letters", :to => "static#legacy_custom_letters", :constraints => {:format => 'html'}
  get "name-signs", :to => "static#legacy_name_signs", :constraints => {:format => 'html'}

  resources :advertising_campaigns
  resources :product_types
  resources :partners
  resources :updates
  resources :images

  if Rails.env.development?
    #MailPreview routes
    mount ContactMailer::Preview => 'contact_preview'
    mount UpdateMailer::Preview => 'update_preview'
    mount OrderMailer::Preview => 'order_preview'
    mount MarketingMailer::Preview => 'marketing_preview'
  end

  devise_for :radmins
  authenticate :radmin do
    mount Resque::Server.new, :at => '/jobs', as: 'jobs'
    get '/jobs/bcd admin' => 'admin#index' #Trick to add a link back to BCD admin from Resque dashboard
  end

  devise_for :users, :controllers => {:registrations => 'registrations', :sessions => 'sessions', :passwords => 'passwords'}
  devise_scope :user do
    get "account/edit" => "registrations#edit"#, :as => :edit_user_registration
    get "/guest_registration" => "sessions#guest_registration", :as => :guest_registration
    post '/register_guest' => "sessions#register_guest", :as => :register_guest
  end

  get '/auth/:provider/callback' => 'authentications#create'

  resources :subcategories do
    member do
      get :model_code
    end
  end
  resources :email_campaigns
  resources :categories do
    member do
      get :subcategories
    end
  end
  resources :products do
    collection do

    end
  end
  resources :authentications, only: [:create, :destroy] do
    collection do
      post :clear_authentications, :as => :clear
    end
  end

  #Admin routes
  resources :admin, :path => :woofay do
    member do
      get :index
      get :become
      get :admin_profile
      patch :update_admin_profile
    end
  end

  post '/woofay/switch_maintenance_mode' => 'admin#switch_maintenance_mode'
  match '/woofay/:email/find_user' => 'admin#find_user', :constraints => {:email => /.*/}, via: :post
  post '/woofay/:email/change_user_status' => 'admin#change_user_status', :constraints => {:email => /.*/}
  post '/woofay/update_downloads_for_user', :to => 'admin#update_downloads_for_user'
  post '/woofay/complete_order', :to => 'admin#complete_order'
  get '/maintenance_mode', :to => 'admin#maintenance_mode', :as => :maintenance_mode
  get '/account_info' => 'admin#account_info', :as => :account_info
  get '/new_product_notification' => 'admin#new_product_notification', :as => :new_product_notification
  post '/send_new_product_notification' => 'admin#send_new_product_notification', :as => :send_new_product_notification
  get 'update_users_download_counts' => 'admin#update_users_download_counts', :as => :update_users_download_counts
  get 'order_fulfillment' => 'admin#order_fulfillment', :as => :order_fulfillment
  patch 'update_order_shipping_status' => 'admin#update_order_shipping_status', :as => :update_order_shipping_status
  get 'sales_report' => 'admin#sales_report', :as => :sales_report
  post 'sales_report_monthly_stats' => 'admin#sales_report_monthly_stats', :as => :sales_report_monthly_stats
  get '/order/:id', :to => 'admin#order'
  get '/transactions_by_month', :to => 'admin#transactions_by_month'
  post '/retire_product', :to => 'products#retire_product'

  #Static routes
  get "maintenance", :to => "static#maintenance"
  get "contact", :to => "static#contact"
  post "send_contact_email", :to => "static#send_contact_email"
  get "terms_of_service", :to => "static#terms_of_service"
  get "privacy_policy", :to => "static#privacy_policy"
  get "coppa_policy", :to => "static#coppa_policy"
  get "faq", :to => "static#faq"
  get "new_user_tutorial", :to => "static#new_user_tutorial"

  #download routes
  get "download/error", :to => "downloads#error"
  get "download/:product_code", :to => "downloads#download"
  get "download_parts_list/:parts_list_id", :to => "downloads#download_parts_list"
  get "guest_download_parts_list/:parts_list_id/:order_id", :to => "downloads#guest_download_parts_list"
  get "guest_download", :to => "downloads#guest_download"
  get "guest_downloads", :to => "downloads#guest_downloads"
  get "download_link_error", :to => "downloads#link_error"


  #account routes
  get "account", :to => "account#index"
  get "account/order_history", :to => "account#order_history"
  get "account/order/:request_id", :to => "account#order"
  get "unsubscribe", :to => "account#unsubscribe_from_emails"

  #store routes
  get "store/products/:product_type_name", :to => "store#products"
  get "store/products/:product_type_name/:category_name", :to => "store#categories", :path => "store/products/:product_type_name/:category_name", :as => :store_categories
  get "store/instructions", :to => "store#instructions"
  get "store/kits", :to => "store#kits"
  get "store/models", :to => "store#models"
  get "thank_you", :to => "store#thank_you_for_your_order"
  get "order_test", :to => "store#order_confirmation_email_test"
  get "physical_order_test", :to => "store#physical_order_email_test"
  get "store", :to => "store#index"
  post "add_to_cart/:product_code", :to => "store#add_to_cart"
  get "add_to_cart/:product_code", :to => "store#add_to_cart"
  get "cart", :to => "store#cart"
  post "empty_cart", :to => "store#empty_cart"
  post "remove_item_from_cart/:id", :to => "store#remove_item_from_cart"
  post "update_item_in_cart", :to => "store#update_item_in_cart"
  get "checkout", :to => "store#checkout"
  get "enter_address", :to => "store#enter_address"
  post "save_order", :to => "store#save_order"
  post "submit_order", :to => "store#submit_order"
  post "listener", :to => "store#listener"
  post "validate_street_address", :to => "store#validate_street_address"

  get "product_details/:product_code/:product_name", :to => "store#product_details", :path => ":product_code/:product_name"

  root :to => "static#index"
end
