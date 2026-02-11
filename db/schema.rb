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

ActiveRecord::Schema[8.1].define(version: 2026_02_11_200800) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "ai_estimated_score"
    t.datetime "ai_last_updated_at"
    t.text "ai_summary"
    t.decimal "average_score", precision: 3, scale: 2
    t.string "category", null: false
    t.virtual "city", type: :string, as: "(metadata ->> 'city'::text)", stored: true
    t.datetime "created_at", null: false
    t.uuid "created_by_user_id"
    t.jsonb "metadata", default: {}
    t.boolean "metadata_edited_by_user", default: false
    t.string "name", null: false
    t.virtual "producer", type: :string, as: "(metadata ->> 'producer'::text)", stored: true
    t.virtual "release_year", type: :string, as: "(metadata ->> 'release_year'::text)", stored: true
    t.integer "reviews_count", default: 0
    t.virtual "season", type: :string, as: "(metadata ->> 'season'::text)", stored: true
    t.string "subcategory", null: false
    t.datetime "updated_at", null: false
    t.virtual "vintage", type: :string, as: "(metadata ->> 'vintage'::text)", stored: true
    t.index "name, ((metadata ->> 'city'::text))", name: "index_items_unique_places", unique: true, where: "((subcategory)::text = ANY ((ARRAY['Restaurants'::character varying, 'Bars'::character varying, 'Parks'::character varying, 'Museums'::character varying])::text[]))"
    t.index ["category", "subcategory"], name: "index_items_on_category_and_subcategory"
    t.index ["city"], name: "index_items_on_city"
    t.index ["created_by_user_id"], name: "index_items_on_created_by_user_id"
    t.index ["name", "producer", "vintage"], name: "index_items_unique_wine", unique: true, where: "((subcategory)::text = 'Wine'::text)"
    t.index ["name", "producer"], name: "index_items_unique_beer_liquor", unique: true, where: "((subcategory)::text = ANY ((ARRAY['Beer'::character varying, 'Liquor'::character varying])::text[]))"
    t.index ["name", "release_year"], name: "index_items_unique_movies", unique: true, where: "((subcategory)::text = 'Movies'::text)"
    t.index ["name", "season"], name: "index_items_unique_tv_shows", unique: true, where: "((subcategory)::text = 'TV Shows'::text)"
    t.index ["producer"], name: "index_items_on_producer"
    t.index ["release_year"], name: "index_items_on_release_year"
    t.index ["season"], name: "index_items_on_season"
    t.index ["vintage"], name: "index_items_on_vintage"
  end

  create_table "reviews", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.uuid "item_id", null: false
    t.integer "score", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["item_id"], name: "index_reviews_on_item_id"
    t.index ["user_id", "item_id"], name: "index_reviews_on_user_id_and_item_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.string "uid"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "items", "users", column: "created_by_user_id"
  add_foreign_key "reviews", "items"
  add_foreign_key "reviews", "users"
end
