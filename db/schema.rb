# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_05_09_120001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "advertising_campaigns", id: :serial, force: :cascade do |t|
    t.integer "partner_id"
    t.string "reference_code", limit: 10
    t.boolean "campaign_live", default: false
    t.string "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["partner_id"], name: "index_advertising_campaigns_on_partner_id"
  end

  create_table "audits", id: :serial, force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at", precision: nil
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "authentications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["user_id"], name: "index_authentications_on_user_id"
  end

  create_table "backend_notifications", id: :serial, force: :cascade do |t|
    t.text "message"
    t.integer "dismissed_by_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["dismissed_by_id"], name: "index_backend_notifications_on_dismissed_by_id"
  end

  create_table "backend_oauth_tokens", force: :cascade do |t|
    t.integer "provider"
    t.string "access_token"
    t.string "refresh_token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cart_items", id: :serial, force: :cascade do |t|
    t.integer "cart_id"
    t.integer "product_id"
    t.integer "quantity"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "ready_for_public", default: false
    t.string "image"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "colors", id: :serial, force: :cascade do |t|
    t.integer "bl_id", limit: 2
    t.integer "ldraw_id", limit: 2
    t.integer "lego_id", limit: 2
    t.string "name", limit: 50
    t.string "bl_name", limit: 50
    t.string "lego_name", limit: 50
    t.string "ldraw_rgb", limit: 6
    t.string "rgb", limit: 6
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "downloads", id: :serial, force: :cascade do |t|
    t.integer "product_id"
    t.integer "count", default: 0
    t.integer "user_id"
    t.integer "remaining", default: 5
    t.string "download_token"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["product_id"], name: "index_downloads_on_product_id"
    t.index ["user_id"], name: "index_downloads_on_user_id"
  end

  create_table "elements", id: :serial, force: :cascade do |t|
    t.integer "part_id"
    t.integer "color_id"
    t.string "image"
    t.string "original_image_url"
    t.string "guid", limit: 36
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["color_id"], name: "index_elements_on_color_id"
    t.index ["part_id", "color_id"], name: "index_elements_on_part_id_and_color_id", unique: true
    t.index ["part_id"], name: "index_elements_on_part_id"
  end

  create_table "email_campaigns", id: :serial, force: :cascade do |t|
    t.text "description"
    t.integer "click_throughs", default: 0
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "message"
    t.string "subject"
    t.integer "emails_sent", default: 0
    t.string "guid"
    t.string "image"
    t.string "redirect_link"
  end

  create_table "images", id: :serial, force: :cascade do |t|
    t.string "url"
    t.integer "product_id"
    t.integer "category_id"
    t.string "location"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "etsy_listing_image_id"
    t.integer "position"
    t.index ["category_id"], name: "index_images_on_category_id"
    t.index ["product_id"], name: "index_images_on_product_id"
  end

  create_table "instant_payment_notifications", id: :serial, force: :cascade do |t|
    t.string "payment_status"
    t.string "notify_version"
    t.string "request_id"
    t.string "verify_sign"
    t.string "payer_email"
    t.string "txn_id"
    t.json "params"
    t.integer "order_id"
    t.boolean "processed", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["order_id"], name: "index_instant_payment_notifications_on_order_id"
  end

  create_table "line_items", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.integer "product_id"
    t.integer "quantity"
    t.decimal "total_price"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "third_party_line_item_identifier"
    t.datetime "third_party_line_item_paid_at"
    t.index ["order_id"], name: "index_line_items_on_order_id"
    t.index ["product_id"], name: "index_line_items_on_product_id"
  end

  create_table "lots", id: :serial, force: :cascade do |t|
    t.integer "parts_list_id"
    t.integer "element_id"
    t.integer "quantity"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "note", default: ""
    t.index ["element_id"], name: "index_lots_on_element_id"
    t.index ["parts_list_id", "element_id"], name: "index_lots_on_parts_list_id_and_element_id", unique: true
    t.index ["parts_list_id"], name: "index_lots_on_parts_list_id"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "transaction_id", limit: 50
    t.string "request_id", limit: 50
    t.string "status", limit: 30
    t.string "address_state"
    t.string "address_street1"
    t.string "address_street2"
    t.string "address_country"
    t.string "address_zip"
    t.string "address_city"
    t.string "address_name"
    t.string "first_name"
    t.string "last_name"
    t.integer "shipping_status"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "source", default: 0
    t.string "third_party_order_identifier"
    t.boolean "confirmation_email_sent", default: false
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "partners", id: :serial, force: :cascade do |t|
    t.string "name", limit: 40
    t.string "url", limit: 40
    t.string "contact", limit: 40
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "parts", id: :serial, force: :cascade do |t|
    t.string "bl_id", limit: 20
    t.string "ldraw_id", limit: 20
    t.string "lego_id", limit: 20
    t.string "name"
    t.boolean "check_bricklink", default: true
    t.boolean "check_rebrickable", default: true
    t.jsonb "alternate_nos"
    t.boolean "is_obsolete", default: false
    t.string "year_from", limit: 4
    t.string "year_to", limit: 4
    t.jsonb "brickowl_ids"
    t.boolean "is_lsynth", default: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "bricklink_state", default: 0
  end

  create_table "parts_lists", id: :serial, force: :cascade do |t|
    t.string "parts_list_type"
    t.string "name"
    t.integer "product_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "approved", default: false
    t.json "parts"
    t.text "bricklink_xml"
    t.text "ldr"
    t.string "original_filename"
    t.string "file"
    t.string "jid"
    t.index ["product_id"], name: "index_parts_lists_on_product_id"
  end

  create_table "pinterest_boards", force: :cascade do |t|
    t.string "topic", null: false
    t.string "pinterest_native_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pinterest_pins", force: :cascade do |t|
    t.bigint "pinterest_board_id", null: false
    t.bigint "product_id", null: false
    t.bigint "image_id", null: false
    t.string "pinterest_native_id", null: false
    t.string "link", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["image_id"], name: "index_pinterest_pins_on_image_id"
    t.index ["pinterest_board_id"], name: "index_pinterest_pins_on_pinterest_board_id"
    t.index ["product_id"], name: "index_pinterest_pins_on_product_id"
  end

  create_table "product_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "image"
    t.boolean "ready_for_public", default: false
    t.text "comes_with_description"
    t.string "comes_with_title"
    t.boolean "digital_product", default: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "products", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "product_type_id"
    t.integer "category_id"
    t.integer "subcategory_id"
    t.string "product_code"
    t.text "description"
    t.decimal "discount_percentage", default: "0.0"
    t.decimal "price"
    t.boolean "ready_for_public", default: false
    t.string "pdf"
    t.string "tweet"
    t.boolean "free", default: false
    t.integer "quantity", default: 1
    t.boolean "alternative_build", default: false
    t.string "youtube_url"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "featured", default: false
    t.string "designer", default: "brian_lyles"
    t.string "etsy_listing_id"
    t.string "etsy_listing_file_id"
    t.string "etsy_listing_state"
    t.string "etsy_listing_url"
    t.datetime "etsy_created_at", precision: nil
    t.datetime "etsy_updated_at", precision: nil
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["product_type_id"], name: "index_products_on_product_type_id"
    t.index ["subcategory_id"], name: "index_products_on_subcategory_id"
  end

  create_table "radmins", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0
    t.datetime "locked_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["email"], name: "index_radmins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_radmins_on_reset_password_token", unique: true
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "subcategories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "category_id"
    t.string "code"
    t.boolean "ready_for_public", default: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["category_id"], name: "index_subcategories_on_category_id"
  end

  create_table "switches", id: :serial, force: :cascade do |t|
    t.string "switch", limit: 30
    t.boolean "switch_on", default: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "third_party_receipts", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.integer "source", null: false
    t.string "third_party_receipt_identifier", null: false
    t.string "third_party_order_status", null: false
    t.boolean "third_party_is_paid"
    t.datetime "third_party_created_at"
    t.datetime "third_party_updated_at"
    t.text "raw_response_body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_third_party_receipts_on_order_id"
    t.index ["source"], name: "index_third_party_receipts_on_source"
    t.index ["third_party_is_paid"], name: "index_third_party_receipts_on_third_party_is_paid"
    t.index ["third_party_order_status"], name: "index_third_party_receipts_on_third_party_order_status"
    t.index ["third_party_receipt_identifier"], name: "index_third_party_receipts_on_third_party_receipt_identifier"
  end

  create_table "updates", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.text "body"
    t.string "image_align"
    t.string "image"
    t.boolean "live", default: false
    t.string "link"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "user_parts_lists", id: :serial, force: :cascade do |t|
    t.integer "parts_list_id"
    t.integer "user_id"
    t.text "values"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["parts_list_id", "user_id"], name: "index_user_parts_lists_on_parts_list_id_and_user_id", unique: true
    t.index ["parts_list_id"], name: "index_user_parts_lists_on_parts_list_id"
    t.index ["user_id"], name: "index_user_parts_lists_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "email_preference", default: 2
    t.string "account_status", limit: 1, default: "A"
    t.string "referrer_code", limit: 10
    t.integer "failed_attempts", default: 0
    t.datetime "locked_at", precision: nil
    t.boolean "tos_accepted", default: false
    t.string "guid"
    t.string "unsubscribe_token"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "source", default: 0
    t.string "third_party_user_identifier"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "taggings", "tags"
end
