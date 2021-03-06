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

ActiveRecord::Schema.define(version: 20160503075533) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appointment_availabilities", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "for_date"
    t.text     "map"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "appointment_availabilities", ["user_id"], name: "index_appointment_availabilities_on_user_id", using: :btree

  create_table "appointment_details", force: :cascade do |t|
    t.integer  "appointment_id"
    t.text     "note"
    t.text     "extra_details"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "appointment_details", ["appointment_id"], name: "index_appointment_details_on_appointment_id", using: :btree

  create_table "appointment_proposal_infos", force: :cascade do |t|
    t.integer  "appointment_id"
    t.boolean  "primary"
    t.integer  "doctor_id"
    t.datetime "date_from"
    t.datetime "date_to"
    t.datetime "anytime_for_date"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "appointment_proposal_infos", ["appointment_id"], name: "index_appointment_proposal_infos_on_appointment_id", using: :btree
  add_index "appointment_proposal_infos", ["doctor_id"], name: "index_appointment_proposal_infos_on_doctor_id", using: :btree

  create_table "appointments", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "patient_id"
    t.integer  "doctor_id"
    t.integer  "user_id"
    t.boolean  "scheduled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "proposal"
  end

  add_index "appointments", ["doctor_id"], name: "index_appointments_on_doctor_id", using: :btree
  add_index "appointments", ["patient_id"], name: "index_appointments_on_patient_id", using: :btree
  add_index "appointments", ["scheduled"], name: "index_appointments_on_scheduled", using: :btree
  add_index "appointments", ["start_date"], name: "index_appointments_on_start_date", using: :btree
  add_index "appointments", ["user_id"], name: "index_appointments_on_user_id", using: :btree

  create_table "avatars", force: :cascade do |t|
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "user_id"
  end

  add_index "avatars", ["user_id"], name: "index_avatars_on_user_id", using: :btree

  create_table "blogs", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "body"
    t.string   "m_title"
    t.string   "m_description"
    t.string   "m_keywords"
    t.string   "slug"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "published"
    t.datetime "published_at"
  end

  add_index "blogs", ["user_id"], name: "index_blogs_on_user_id", using: :btree

  create_table "chat_messages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "to_user"
    t.text     "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "read"
    t.integer  "chat_id"
  end

  add_index "chat_messages", ["chat_id"], name: "index_chat_messages_on_chat_id", using: :btree
  add_index "chat_messages", ["user_id"], name: "index_chat_messages_on_user_id", using: :btree

  create_table "chats", force: :cascade do |t|
    t.integer  "chat_messages_count"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "user_id"
    t.integer  "unread_count"
  end

  add_index "chats", ["user_id"], name: "index_chats_on_user_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "alt"
    t.string   "description"
  end

  add_index "images", ["user_id"], name: "index_images_on_user_id", using: :btree

  create_table "menu_items", force: :cascade do |t|
    t.string   "href"
    t.string   "link_text"
    t.integer  "menu_item_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "menu_items", ["menu_item_id"], name: "index_menu_items_on_menu_item_id", using: :btree

  create_table "offered_service_avatars", force: :cascade do |t|
    t.integer  "offered_service_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "offered_service_avatars", ["offered_service_id"], name: "index_offered_service_avatars_on_offered_service_id", using: :btree

  create_table "offered_services", force: :cascade do |t|
    t.text     "body"
    t.string   "title"
    t.string   "m_title"
    t.string   "m_description"
    t.string   "m_keywords"
    t.string   "slug"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "offered_services", ["user_id"], name: "index_offered_services_on_user_id", using: :btree

  create_table "pages", force: :cascade do |t|
    t.string   "body"
    t.text     "title"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "m_title"
    t.string   "m_description"
    t.string   "m_keywords"
    t.string   "slug"
  end

  add_index "pages", ["slug"], name: "index_pages_on_slug", unique: true, using: :btree
  add_index "pages", ["user_id"], name: "index_pages_on_user_id", using: :btree

  create_table "price_categories", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "price_items", force: :cascade do |t|
    t.integer  "price_category_id"
    t.text     "name"
    t.decimal  "price",              precision: 6, scale: 2
    t.text     "details"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "offered_service_id"
  end

  add_index "price_items", ["offered_service_id"], name: "index_price_items_on_offered_service_id", using: :btree
  add_index "price_items", ["price_category_id"], name: "index_price_items_on_price_category_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "bio"
    t.string   "position"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "name"
    t.string   "phone_number"
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "remember_digest"
    t.string   "activation_digest"
    t.boolean  "activated"
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "registered",        default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  add_foreign_key "appointment_availabilities", "users"
  add_foreign_key "appointment_details", "appointments"
  add_foreign_key "appointment_proposal_infos", "appointments"
  add_foreign_key "appointments", "users"
  add_foreign_key "avatars", "users"
  add_foreign_key "blogs", "users"
  add_foreign_key "chat_messages", "chats"
  add_foreign_key "chat_messages", "users"
  add_foreign_key "chats", "users"
  add_foreign_key "images", "users"
  add_foreign_key "menu_items", "menu_items"
  add_foreign_key "offered_service_avatars", "offered_services"
  add_foreign_key "offered_services", "users"
  add_foreign_key "pages", "users"
  add_foreign_key "price_items", "offered_services"
  add_foreign_key "price_items", "price_categories"
  add_foreign_key "profiles", "users"
end
