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

ActiveRecord::Schema[8.1].define(version: 2026_08_07_014219) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.string "namespace"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.integer "allowed_radius_meters", default: 100, null: false
    t.datetime "created_at", null: false
    t.date "held_on", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "venue"
    t.decimal "venue_lat", precision: 9, scale: 6
    t.decimal "venue_lng", precision: 9, scale: 6
  end

  create_table "ranks", force: :cascade do |t|
    t.text "benefit_description"
    t.datetime "created_at", null: false
    t.integer "min_stamps", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["min_stamps"], name: "index_ranks_on_min_stamps", unique: true
  end

  create_table "stamps", force: :cascade do |t|
    t.datetime "checked_in_at", null: false
    t.decimal "checkin_lat", precision: 9, scale: 6
    t.decimal "checkin_lng", precision: 9, scale: 6
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.bigint "granted_by_admin_user_id"
    t.integer "source", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "visitor_id", null: false
    t.index ["event_id"], name: "index_stamps_on_event_id"
    t.index ["granted_by_admin_user_id"], name: "index_stamps_on_granted_by_admin_user_id"
    t.index ["visitor_id", "event_id"], name: "index_stamps_on_visitor_id_and_event_id", unique: true
    t.index ["visitor_id"], name: "index_stamps_on_visitor_id"
  end

  create_table "visitors", force: :cascade do |t|
    t.integer "age_band"
    t.string "avatar_url"
    t.string "card_number"
    t.integer "category"
    t.string "company_name"
    t.datetime "created_at", null: false
    t.string "display_name"
    t.integer "gender"
    t.string "line_user_id"
    t.datetime "profile_prompted_at"
    t.integer "resident"
    t.datetime "updated_at", null: false
    t.index ["card_number"], name: "index_visitors_on_card_number", unique: true
    t.index ["line_user_id"], name: "index_visitors_on_line_user_id", unique: true
    t.check_constraint "line_user_id IS NOT NULL OR card_number IS NOT NULL", name: "visitors_line_user_id_or_card_number_check"
  end

  add_foreign_key "stamps", "admin_users", column: "granted_by_admin_user_id"
  add_foreign_key "stamps", "events"
  add_foreign_key "stamps", "visitors"
end
