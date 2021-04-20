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

ActiveRecord::Schema.define(version: 2021_04_20_191302) do

  create_table "active_storage_attachments", charset: "latin1", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "latin1", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "latin1", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "attachments", charset: "latin1", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.bigint "report_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["report_id"], name: "index_attachments_on_report_id"
  end

  create_table "reports", charset: "latin1", force: :cascade do |t|
    t.integer "year", null: false
    t.integer "number", null: false
    t.integer "shop_order", null: false
    t.string "customer_code", limit: 6, null: false
    t.string "process_code", limit: 3, null: false
    t.string "part", limit: 17, null: false
    t.string "sub", limit: 1
    t.date "sent_on", null: false
    t.column "discovery_stage", "enum('before','during','after')"
    t.column "disposition", "enum('unprocessed','partial','complete')"
    t.float "pounds"
    t.integer "pieces"
    t.string "customer_name", null: false
    t.string "part_name", null: false
    t.string "purchase_order"
    t.bigint "user_id", null: false
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "entry_finished", default: false, null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_reports_on_deleted_at"
    t.index ["user_id"], name: "index_reports_on_user_id"
    t.index ["year", "number"], name: "unique_dmr_number", unique: true
  end

  create_table "users", charset: "latin1", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.integer "employee_number", null: false
    t.string "uid"
    t.string "remember_token"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["employee_number"], name: "index_users_on_employee_number", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attachments", "reports"
  add_foreign_key "reports", "users"
end
