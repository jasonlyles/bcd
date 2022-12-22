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

ActiveRecord::Schema.define(version: 20221222191529) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "advertising_campaigns", force: :cascade do |t|
    t.integer  "partner_id"
    t.string   "reference_code", limit: 10
    t.boolean  "campaign_live",             default: false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["partner_id"], name: "index_advertising_campaigns_on_partner_id", using: :btree
  end

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index", using: :btree
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index", using: :btree
    t.index ["created_at"], name: "index_audits_on_created_at", using: :btree
    t.index ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
    t.index ["user_id", "user_type"], name: "user_index", using: :btree
  end

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_authentications_on_user_id", using: :btree
  end

  create_table "backend_notifications", force: :cascade do |t|
    t.text     "message"
    t.integer  "dismissed_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["dismissed_by_id"], name: "index_backend_notifications_on_dismissed_by_id", using: :btree
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer  "cart_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cart_id"], name: "index_cart_items_on_cart_id", using: :btree
    t.index ["product_id"], name: "index_cart_items_on_product_id", using: :btree
  end

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_carts_on_user_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "ready_for_public", default: false
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "colors", force: :cascade do |t|
    t.integer  "bl_id",      limit: 2
    t.integer  "ldraw_id",   limit: 2
    t.integer  "lego_id",    limit: 2
    t.string   "name",       limit: 50
    t.string   "bl_name",    limit: 50
    t.string   "lego_name",  limit: 50
    t.string   "ldraw_rgb",  limit: 6
    t.string   "rgb",        limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "downloads", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "count",          default: 0
    t.integer  "user_id"
    t.integer  "remaining",      default: 5
    t.string   "download_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["product_id"], name: "index_downloads_on_product_id", using: :btree
    t.index ["user_id"], name: "index_downloads_on_user_id", using: :btree
  end

  create_table "elements", force: :cascade do |t|
    t.integer  "part_id"
    t.integer  "color_id"
    t.string   "image"
    t.string   "original_image_url"
    t.string   "guid",               limit: 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["color_id"], name: "index_elements_on_color_id", using: :btree
    t.index ["part_id", "color_id"], name: "index_elements_on_part_id_and_color_id", unique: true, using: :btree
    t.index ["part_id"], name: "index_elements_on_part_id", using: :btree
  end

  create_table "email_campaigns", force: :cascade do |t|
    t.text     "description"
    t.integer  "click_throughs", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message"
    t.string   "subject"
    t.integer  "emails_sent",    default: 0
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
    t.index ["category_id"], name: "index_images_on_category_id", using: :btree
    t.index ["product_id"], name: "index_images_on_product_id", using: :btree
  end

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
    t.index ["order_id"], name: "index_instant_payment_notifications_on_order_id", using: :btree
  end

  create_table "line_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.decimal  "total_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["order_id"], name: "index_line_items_on_order_id", using: :btree
    t.index ["product_id"], name: "index_line_items_on_product_id", using: :btree
  end

  create_table "lots", force: :cascade do |t|
    t.integer  "parts_list_id"
    t.integer  "element_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "note",          default: ""
    t.index ["element_id"], name: "index_lots_on_element_id", using: :btree
    t.index ["parts_list_id", "element_id"], name: "index_lots_on_parts_list_id_and_element_id", unique: true, using: :btree
    t.index ["parts_list_id"], name: "index_lots_on_parts_list_id", using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "transaction_id",  limit: 50
    t.string   "request_id",      limit: 50
    t.string   "status",          limit: 10
    t.string   "address_state"
    t.string   "address_street1"
    t.string   "address_street2"
    t.string   "address_country"
    t.string   "address_zip"
    t.string   "address_city"
    t.string   "address_name"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "shipping_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "partners", force: :cascade do |t|
    t.string   "name",       limit: 40
    t.string   "url",        limit: 40
    t.string   "contact",    limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parts", force: :cascade do |t|
    t.string   "bl_id",             limit: 20
    t.string   "ldraw_id",          limit: 20
    t.string   "lego_id",           limit: 20
    t.string   "name"
    t.boolean  "check_bricklink",              default: true
    t.boolean  "check_rebrickable",            default: true
    t.jsonb    "alternate_nos"
    t.boolean  "is_obsolete",                  default: false
    t.string   "year_from",         limit: 4
    t.string   "year_to",           limit: 4
    t.jsonb    "brickowl_ids"
    t.boolean  "is_lsynth",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parts_lists", force: :cascade do |t|
    t.string   "parts_list_type"
    t.string   "name"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved",          default: false
    t.json     "parts"
    t.text     "bricklink_xml"
    t.text     "ldr"
    t.string   "original_filename"
    t.string   "file"
    t.index ["product_id"], name: "index_parts_lists_on_product_id", using: :btree
  end

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
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "product_type_id"
    t.integer  "category_id"
    t.integer  "subcategory_id"
    t.string   "product_code"
    t.text     "description"
    t.decimal  "discount_percentage", default: "0.0"
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
    t.boolean  "featured",            default: false
    t.string   "designer",            default: "brian_lyles"
    t.index ["category_id"], name: "index_products_on_category_id", using: :btree
    t.index ["product_type_id"], name: "index_products_on_product_type_id", using: :btree
    t.index ["subcategory_id"], name: "index_products_on_subcategory_id", using: :btree
  end

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
    t.index ["email"], name: "index_radmins_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_radmins_on_reset_password_token", unique: true, using: :btree
  end

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
    t.index ["product_id"], name: "index_sales_summaries_on_product_id", using: :btree
    t.index ["sales_report_id"], name: "index_sales_summaries_on_sales_report_id", using: :btree
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  create_table "subcategories", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "category_id"
    t.string   "code"
    t.boolean  "ready_for_public", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["category_id"], name: "index_subcategories_on_category_id", using: :btree
  end

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
    t.boolean  "live",        default: false
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_parts_lists", force: :cascade do |t|
    t.integer  "parts_list_id"
    t.integer  "user_id"
    t.text     "values"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["parts_list_id", "user_id"], name: "index_user_parts_lists_on_parts_list_id_and_user_id", unique: true, using: :btree
    t.index ["parts_list_id"], name: "index_user_parts_lists_on_parts_list_id", using: :btree
    t.index ["user_id"], name: "index_user_parts_lists_on_user_id", using: :btree
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
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
