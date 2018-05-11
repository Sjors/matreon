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

ActiveRecord::Schema.define(version: 20180502093551) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contributions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "billing_day_of_month"
    t.index ["user_id"], name: "index_contributions_on_user_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "amount"
    t.datetime "paid_at"
    t.string "charge_invoice_id"
    t.datetime "polled_at"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "emailed_at"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "podcasts", force: :cascade do |t|
    t.string "guid"
    t.datetime "pub_date"
    t.string "title"
    t.text "description"
    t.string "url"
    t.boolean "external"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "podcast_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["podcast_token"], name: "index_users_on_podcast_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "contributions", "users"
  add_foreign_key "invoices", "users"
end
