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

ActiveRecord::Schema[8.1].define(version: 2026_01_20_143834) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "friendships", force: :cascade do |t|
    t.bigint "accepter_id", null: false
    t.datetime "created_at", null: false
    t.text "message"
    t.bigint "requester_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["accepter_id"], name: "index_friendships_on_accepter_id"
    t.index ["requester_id", "accepter_id"], name: "index_friendships_on_requester_id_and_accepter_id", unique: true
    t.index ["requester_id"], name: "index_friendships_on_requester_id"
    t.check_constraint "requester_id <> accepter_id", name: "chk_friendships_not_self"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "exp"
    t.string "jti"
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti", unique: true
  end

  create_table "shopping_list_invitations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "invitee_id", null: false
    t.bigint "inviter_id", null: false
    t.bigint "shopping_list_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["invitee_id"], name: "index_shopping_list_invitations_on_invitee_id"
    t.index ["inviter_id"], name: "index_shopping_list_invitations_on_inviter_id"
    t.index ["shopping_list_id", "invitee_id"], name: "idx_shopping_list_invitations_unique", unique: true
    t.index ["shopping_list_id"], name: "index_shopping_list_invitations_on_shopping_list_id"
  end

  create_table "shopping_list_items", force: :cascade do |t|
    t.bigint "added_by_id", null: false
    t.datetime "created_at", null: false
    t.bigint "edited_by_id"
    t.string "name"
    t.bigint "shopping_list_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["added_by_id"], name: "index_shopping_list_items_on_added_by_id"
    t.index ["edited_by_id"], name: "index_shopping_list_items_on_edited_by_id"
    t.index ["shopping_list_id"], name: "index_shopping_list_items_on_shopping_list_id"
  end

  create_table "shopping_list_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "shopping_list_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["shopping_list_id", "user_id"], name: "index_shopping_list_users_on_shopping_list_id_and_user_id", unique: true
    t.index ["shopping_list_id"], name: "index_shopping_list_users_on_shopping_list_id"
    t.index ["user_id"], name: "index_shopping_list_users_on_user_id"
  end

  create_table "shopping_lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "owner_id", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_shopping_lists_on_owner_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.string "nickname"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wishlist_items", force: :cascade do |t|
    t.bigint "booked_by_user_id"
    t.datetime "created_at", null: false
    t.string "currency", default: "USD"
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.integer "status", default: 0
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url"
    t.bigint "user_id", null: false
    t.index ["booked_by_user_id"], name: "index_wishlist_items_on_booked_by_user_id"
    t.index ["user_id"], name: "index_wishlist_items_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "friendships", "users", column: "accepter_id"
  add_foreign_key "friendships", "users", column: "requester_id"
  add_foreign_key "shopping_list_invitations", "shopping_lists"
  add_foreign_key "shopping_list_invitations", "users", column: "invitee_id"
  add_foreign_key "shopping_list_invitations", "users", column: "inviter_id"
  add_foreign_key "shopping_list_items", "shopping_lists"
  add_foreign_key "shopping_list_items", "users", column: "added_by_id"
  add_foreign_key "shopping_list_items", "users", column: "edited_by_id"
  add_foreign_key "shopping_list_users", "shopping_lists"
  add_foreign_key "shopping_list_users", "users"
  add_foreign_key "shopping_lists", "users", column: "owner_id"
  add_foreign_key "wishlist_items", "users"
  add_foreign_key "wishlist_items", "users", column: "booked_by_user_id"
end
