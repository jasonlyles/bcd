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

ActiveRecord::Schema.define(version: 20140806005822) do

  create_table "advertising_campaigns", force: :cascade do |t|
    t.integer  "partner_id"
    t.string   "reference_code", limit: 10
    t.boolean  "campaign_live",              default: false
    t.string   "description",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "advertising_campaigns", ["partner_id"], name: "index_advertising_campaigns_on_partner_id"

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id"

  create_table "cart_items", force: :cascade do |t|
    t.integer  "cart_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cart_items", ["cart_id"], name: "index_cart_items_on_cart_id"
  add_index "cart_items", ["product_id"], name: "index_cart_items_on_product_id"

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "carts", ["user_id"], name: "index_carts_on_user_id"

  create_table "categories", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.text     "description"
    t.boolean  "ready_for_public",             default: false
    t.string   "image",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "image_processing",             default: false
  end

  create_table "downloads", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "count",                      default: 0
    t.integer  "user_id"
    t.integer  "remaining",                  default: 5
    t.string   "download_token", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "downloads", ["product_id"], name: "index_downloads_on_product_id"
  add_index "downloads", ["user_id"], name: "index_downloads_on_user_id"

  create_table "email_campaigns", force: :cascade do |t|
    t.text     "description"
    t.integer  "click_throughs",               default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "image_processing",             default: false
    t.text     "message"
    t.string   "subject",          limit: 255
    t.integer  "emails_sent",                  default: 0
    t.string   "guid",             limit: 255
    t.string   "image",            limit: 255
    t.string   "redirect_link",    limit: 255
  end

  create_table "images", force: :cascade do |t|
    t.string   "url",            limit: 255
    t.integer  "product_id"
    t.integer  "category_id"
    t.string   "location",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "url_processing",             default: false
  end

  add_index "images", ["category_id"], name: "index_images_on_category_id"
  add_index "images", ["product_id"], name: "index_images_on_product_id"

  create_table "line_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.decimal  "total_price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "line_items", ["order_id"], name: "index_line_items_on_order_id"
  add_index "line_items", ["product_id"], name: "index_line_items_on_product_id"

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "transaction_id",   limit: 50
    t.string   "request_id",       limit: 50
    t.string   "status",           limit: 10
    t.string   "address_state",    limit: 255
    t.string   "address_street_1", limit: 255
    t.string   "address_street_2", limit: 255
    t.string   "address_country",  limit: 255
    t.string   "address_zip",      limit: 255
    t.string   "address_city",     limit: 255
    t.string   "address_name",     limit: 255
    t.string   "first_name",       limit: 255
    t.string   "last_name",        limit: 255
    t.integer  "shipping_status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["user_id"], name: "index_orders_on_user_id"

  create_table "partners", force: :cascade do |t|
    t.string   "name",       limit: 40
    t.string   "url",        limit: 40
    t.string   "contact",    limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parts_lists", force: :cascade do |t|
    t.string   "parts_list_type", limit: 255
    t.string   "name",            limit: 255
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "name_processing",             default: false
  end

  add_index "parts_lists", ["product_id"], name: "index_parts_lists_on_product_id"

  create_table "product_types", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.text     "description"
    t.string   "image",                  limit: 255
    t.boolean  "ready_for_public",                   default: false
    t.text     "comes_with_description"
    t.string   "comes_with_title",       limit: 255
    t.boolean  "digital_product",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "image_processing",                   default: false
  end

  create_table "products", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.integer  "product_type_id"
    t.integer  "category_id"
    t.integer  "subcategory_id"
    t.string   "product_code",        limit: 255
    t.text     "description"
    t.decimal  "discount_percentage",             default: 0.0
    t.decimal  "price"
    t.boolean  "ready_for_public",                default: false
    t.string   "pdf",                 limit: 255
    t.string   "tweet",               limit: 255
    t.boolean  "free",                            default: false
    t.integer  "quantity",                        default: 1
    t.boolean  "alternative_build",               default: false
    t.string   "youtube_url",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pdf_processing",                  default: false
    t.boolean  "featured",                        default: false
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id"
  add_index "products", ["product_type_id"], name: "index_products_on_product_type_id"
  add_index "products", ["subcategory_id"], name: "index_products_on_subcategory_id"

  create_table "radmins", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.integer  "failed_attempts",                    default: 0
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "radmins", ["email"], name: "index_radmins_on_email", unique: true
  add_index "radmins", ["reset_password_token"], name: "index_radmins_on_reset_password_token", unique: true

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

  add_index "sales_summaries", ["product_id"], name: "index_sales_summaries_on_product_id"
  add_index "sales_summaries", ["sales_report_id"], name: "index_sales_summaries_on_sales_report_id"

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "subcategories", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.text     "description"
    t.integer  "category_id"
    t.string   "code",             limit: 255
    t.boolean  "ready_for_public",             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subcategories", ["category_id"], name: "index_subcategories_on_category_id"

  create_table "switches", force: :cascade do |t|
    t.string   "switch",     limit: 30
    t.boolean  "switch_on",             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "updates", force: :cascade do |t|
    t.string   "title",            limit: 255
    t.string   "description",      limit: 255
    t.text     "body"
    t.string   "image_align",      limit: 255
    t.string   "image",            limit: 255
    t.boolean  "live",                         default: false
    t.string   "link",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "image_processing",             default: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.integer  "email_preference",                   default: 2
    t.string   "account_status",         limit: 1,   default: "A"
    t.string   "referrer_code",          limit: 10
    t.integer  "failed_attempts",                    default: 0
    t.datetime "locked_at"
    t.boolean  "tos_accepted",                       default: false
    t.string   "guid",                   limit: 255
    t.string   "unsubscribe_token",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
