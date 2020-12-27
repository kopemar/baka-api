# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_27_231317) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contracts", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type", default: "Contract", null: false
    t.float "work_load"
    t.integer "maximum_working_hours"
    t.integer "employee_id"
    t.integer "working_days", array: true
    t.integer "schedule_id"
  end

  create_table "demands", force: :cascade do |t|
    t.integer "specialization", default: 0, null: false
    t.integer "demand", default: 3, null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "start_date"
    t.date "end_date"
    t.index ["start_time", "end_time", "specialization"], name: "index_demands_on_start_time_and_end_time_and_specialization", unique: true
  end

  create_table "schedules", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "contract_id"
  end

  create_table "shifts", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "end_time"
    t.datetime "start_time"
    t.integer "schedule_id"
    t.integer "duration", default: 8
    t.boolean "user_scheduled", default: false
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "first_name"
    t.string "last_name"
    t.date "birth_date"
    t.string "username"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type", default: "User", null: false
    t.integer "role", default: 0
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "weeks", force: :cascade do |t|
    t.integer "year"
    t.integer "week"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
