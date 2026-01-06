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

ActiveRecord::Schema[8.0].define(version: 2025_11_29_184408) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "assets", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.string "kind"
    t.text "file_url"
    t.integer "width"
    t.integer "height"
    t.integer "order_index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_assets_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "prompt_id", null: false
    t.text "caption"
    t.string "status"
    t.string "kind"
    t.json "data"
    t.datetime "published_at"
    t.datetime "scheduled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prompt_id"], name: "index_posts_on_prompt_id"
  end

  create_table "prompts", force: :cascade do |t|
    t.text "text"
    t.string "lang"
    t.string "tone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "kind", default: "image", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "assets", "posts"
  add_foreign_key "posts", "prompts"
end
