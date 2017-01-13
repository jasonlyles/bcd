# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161230223133) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "advertising_campaigns", force: :cascade do |t|
    t.integer  "partner_id"
    t.string   "reference_code", limit: 10
    t.boolean  "campaign_live",             default: false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "advertising_campaigns", ["partner_id"], name: "index_advertising_campaigns_on_partner_id", using: :btree

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "cart_items", force: :cascade do |t|
    t.integer  "cart_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cart_items", ["cart_id"], name: "index_cart_items_on_cart_id", using: :btree
  add_index "cart_items", ["product_id"], name: "index_cart_items_on_product_id", using: :btree

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "ready_for_public", default: false
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "image_processing", default: false
  end

  create_table "downloads", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "count",          default: 0
    t.integer  "user_id"
    t.integer  "remaining",      default: 5
    t.string   "download_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "downloads", ["product_id"], name: "index_downloads_on_product_id", using: :btree
  add_index "downloads", ["user_id"], name: "index_downloads_on_user_id", using: :btree

  create_table "email_campaigns", force: :cascade do |t|
    t.text     "description"
    t.integer  "click_throughs",   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "image_processing", default: false
    t.text     "message"
    t.string   "subject"
    t.integer  "emails_sent",      default: 0
    t.string   "guid"
    t.string   "image"
    t.string   "redirect_link"
  end

  create_table "images", force: :cascade do |t|
    t.string   "url"
    t.integer  "product_id"
    t.integer  "category_id"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "url_processing", default: false
  end

  add_index "images", ["category_id"], name: "index_images_on_category_id", using: :btree
  add_index "images", ["product_id"], name: "index_images_on_product_id", using: :btree

  create_table "instant_payment_notifications", force: :cascade do |t|
    t.string   "payment_status"
    t.string   "notify_version"
    t.string   "request_id"
    t.string   "verify_sign"
    t.string   "payer_email"
    t.string   "txn_id"
    t.json     "params"
    t.integer  "order_id"
    t.boolean  "processed",      default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "line_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.decimal  "total_price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "line_items", ["order_id"], name: "index_line_items_on_order_id", using: :btree
  add_index "line_items", ["product_id"], name: "index_line_items_on_product_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "transaction_id",   limit: 50
    t.string   "request_id",       limit: 50
    t.string   "status",           limit: 10
    t.string   "address_state"
    t.string   "address_street_1"
    t.string   "address_street_2"
    t.string   "address_country"
    t.string   "address_zip"
    t.string   "address_city"
    t.string   "address_name"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "shipping_status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "partners", force: :cascade do |t|
    t.string   "name",       limit: 40
    t.string   "url",        limit: 40
    t.string   "contact",    limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parts_lists", force: :cascade do |t|
    t.string   "parts_list_type"
    t.string   "name"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "name_processing", default: false
  end

  add_index "parts_lists", ["product_id"], name: "index_parts_lists_on_product_id", using: :btree

  create_table "product_types", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "image"
    t.boolean  "ready_for_public",       default: false
    t.text     "comes_with_description"
    t.string   "comes_with_title"
    t.boolean  "digital_product",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "image_processing",       default: false
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "product_type_id"
    t.integer  "category_id"
    t.integer  "subcategory_id"
    t.string   "product_code"
    t.text     "description"
    t.decimal  "discount_percentage", default: 0.0
    t.decimal  "price"
    t.boolean  "ready_for_public",    default: false
    t.string   "pdf"
    t.string   "tweet"
    t.boolean  "free",                default: false
    t.integer  "quantity",            default: 1
    t.boolean  "alternative_build",   default: false
    t.string   "youtube_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pdf_processing",      default: false
    t.boolean  "featured",            default: false
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["product_type_id"], name: "index_products_on_product_type_id", using: :btree
  add_index "products", ["subcategory_id"], name: "index_products_on_subcategory_id", using: :btree

  create_table "radmins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "radmins", ["email"], name: "index_radmins_on_email", unique: true, using: :btree
  add_index "radmins", ["reset_password_token"], name: "index_radmins_on_reset_password_token", unique: true, using: :btree

  create_table "sales_reports", force: :cascade do |t|
    t.date     "report_date"
    t.boolean  "completed",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_summaries", force: :cascade do |t|
    t.integer  "sales_report_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.decimal  "total_revenue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sales_summaries", ["product_id"], name: "index_sales_summaries_on_product_id", using: :btree
  add_index "sales_summaries", ["sales_report_id"], name: "index_sales_summaries_on_sales_report_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "subcategories", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "category_id"
    t.string   "code"
    t.boolean  "ready_for_public", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subcategories", ["category_id"], name: "index_subcategories_on_category_id", using: :btree

  create_table "switches", force: :cascade do |t|
    t.string   "switch",     limit: 30
    t.boolean  "switch_on",             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "updates", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.text     "body"
    t.string   "image_align"
    t.string   "image"
    t.boolean  "live",             default: false
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "image_processing", default: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                             default: "",    null: false
    t.string   "encrypted_password",                default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "email_preference",                  default: 2
    t.string   "account_status",         limit: 1,  default: "A"
    t.string   "referrer_code",          limit: 10
    t.integer  "failed_attempts",                   default: 0
    t.datetime "locked_at"
    t.boolean  "tos_accepted",                      default: false
    t.string   "guid"
    t.string   "unsubscribe_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
