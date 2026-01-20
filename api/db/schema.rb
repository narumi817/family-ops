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

ActiveRecord::Schema[8.0].define(version: 2026_01_20_123000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "email_verifications", force: :cascade do |t|
    t.bigint "user_id"
    t.string "email", null: false
    t.string "token", null: false
    t.datetime "token_expired_at", null: false
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_email_verifications_on_email"
    t.index ["token"], name: "index_email_verifications_on_token", unique: true
    t.index ["user_id"], name: "index_email_verifications_on_user_id"
  end

  create_table "families", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "family_invitations", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.string "email", null: false
    t.string "token", null: false
    t.datetime "token_expired_at", null: false
    t.bigint "invite_user_id", null: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_family_invitations_on_email"
    t.index ["family_id"], name: "index_family_invitations_on_family_id"
    t.index ["token"], name: "index_family_invitations_on_token", unique: true
  end

  create_table "family_members", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "family_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_family_members_on_family_id"
    t.index ["user_id", "family_id"], name: "index_family_members_on_user_id_and_family_id", unique: true
  end

  create_table "family_task_points", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.bigint "task_id", null: false
    t.integer "points", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id", "task_id"], name: "index_family_task_points_on_family_id_and_task_id", unique: true
    t.index ["family_id"], name: "index_family_task_points_on_family_id"
  end

  create_table "logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "task_id", null: false
    t.datetime "performed_at", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["performed_at"], name: "index_logs_on_performed_at"
    t.index ["task_id", "performed_at"], name: "index_logs_on_task_id_and_performed_at"
    t.index ["task_id"], name: "index_logs_on_task_id"
    t.index ["user_id", "performed_at"], name: "index_logs_on_user_id_and_performed_at"
    t.index ["user_id"], name: "index_logs_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "category", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "family_id"
    t.integer "points", default: 1, null: false
    t.index ["category"], name: "index_tasks_on_category"
    t.index ["family_id"], name: "index_tasks_on_family_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_login_at"
    t.string "provider"
    t.string "uid"
    t.datetime "email_verified_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true, where: "(provider IS NOT NULL)"
  end

  add_foreign_key "email_verifications", "users", on_delete: :cascade
  add_foreign_key "family_invitations", "families", on_delete: :cascade
  add_foreign_key "family_invitations", "users", column: "invite_user_id", on_delete: :cascade
  add_foreign_key "family_members", "families", on_delete: :cascade
  add_foreign_key "family_members", "users", on_delete: :cascade
  add_foreign_key "family_task_points", "families", on_delete: :cascade
  add_foreign_key "family_task_points", "tasks", on_delete: :restrict
  add_foreign_key "logs", "tasks", on_delete: :restrict
  add_foreign_key "logs", "users", on_delete: :restrict
  add_foreign_key "tasks", "families", on_delete: :cascade
end
