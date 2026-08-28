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

ActiveRecord::Schema[8.1].define(version: 2026_08_25_182926) do
  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "app_name"
    t.datetime "created_at", null: false
    t.boolean "disabled", default: false
    t.string "email"
    t.string "name"
    t.string "organisation_content_id"
    t.string "organisation_slug"
    t.text "permissions"
    t.boolean "remotely_signed_out", default: false
    t.string "uid"
    t.datetime "updated_at", null: false
  end
end
