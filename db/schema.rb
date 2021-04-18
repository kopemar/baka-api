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

ActiveRecord::Schema.define(version: 2021_04_18_075250) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contracts", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type", default: "Contract", null: false
    t.integer "maximum_working_hours"
    t.integer "employee_id"
    t.integer "schedule_id"
    t.float "work_load", default: 1.0, null: false
  end

  create_table "contracts_specializations", force: :cascade do |t|
    t.integer "contract_id"
    t.integer "specialization_id"
  end

  create_table "fcm_tokens", force: :cascade do |t|
    t.integer "user_id"
    t.string "fcm_token"
    t.string "client"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "managers", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "schedules", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "contract_id"
  end

  create_table "scheduling_periods", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "organization_id", null: false
    t.boolean "submitted", default: false, null: false
  end

  create_table "scheduling_units", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.integer "scheduling_period_id", null: false
    t.integer "organization_id", null: false
  end

  create_table "shift_templates", force: :cascade do |t|
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.integer "priority", default: 2, null: false
    t.integer "break_minutes", default: 0, null: false
    t.float "duration", default: 0.0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "scheduling_unit_id"
    t.integer "organization_id", null: false
    t.boolean "is_employment_contract"
    t.boolean "excluded"
    t.integer "specialization_id"
    t.integer "parent_template_id"
  end

  create_table "shifts", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "end_time"
    t.datetime "start_time"
    t.integer "schedule_id"
    t.float "duration", default: 8.0
    t.boolean "user_scheduled", default: false
    t.integer "shift_template_id"
    t.integer "break_minutes"
    t.integer "scheduler_type", default: 0
  end

  create_table "specializations", force: :cascade do |t|
    t.string "name", null: false
    t.integer "organization_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id", "name"], name: "index_specializations_on_organization_id_and_name", unique: true
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
    t.integer "organization_id", default: 1
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
