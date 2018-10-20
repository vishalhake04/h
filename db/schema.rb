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

ActiveRecord::Schema.define(version: 20170307153456) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "availabilities", force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "time"
    t.boolean  "mon",        default: false
    t.boolean  "tue",        default: false
    t.boolean  "wed",        default: false
    t.boolean  "thu",        default: false
    t.boolean  "fri",        default: false
    t.boolean  "sat",        default: false
    t.boolean  "sun",        default: false
    t.integer  "user_id"
  end

  add_index "availabilities", ["user_id"], name: "index_availabilities_on_user_id", using: :btree

  create_table "bookings", force: :cascade do |t|
    t.date     "dates"
    t.string   "slots"
    t.boolean  "is_confirmed", default: false
    t.boolean  "is_deleted",   default: false
    t.string   "status",       default: ""
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "stylist_id"
    t.integer  "service_id"
    t.integer  "user_id"
    t.integer  "total_amount"
    t.integer  "total_time"
  end

  add_index "bookings", ["service_id"], name: "index_bookings_on_service_id", using: :btree
  add_index "bookings", ["stylist_id"], name: "index_bookings_on_stylist_id", using: :btree
  add_index "bookings", ["user_id"], name: "index_bookings_on_user_id", using: :btree

  create_table "favourite_stylists", force: :cascade do |t|
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "stylist_id"
    t.integer  "user_id"
    t.boolean  "unfavourite", default: false
  end

  add_index "favourite_stylists", ["stylist_id"], name: "index_favourite_stylists_on_stylist_id", using: :btree
  add_index "favourite_stylists", ["user_id"], name: "index_favourite_stylists_on_user_id", using: :btree

  create_table "featured_professionals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  add_index "featured_professionals", ["user_id"], name: "index_featured_professionals_on_user_id", using: :btree

  create_table "gift_cards", force: :cascade do |t|
    t.string   "gift_code"
    t.string   "to_email"
    t.integer  "amount"
    t.string   "message"
    t.integer  "remaining_amount"
    t.boolean  "is_valid",         default: true
    t.date     "validity"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "user_id"
    t.integer  "gift_owner_id"
  end

  add_index "gift_cards", ["gift_owner_id"], name: "index_gift_cards_on_gift_owner_id", using: :btree
  add_index "gift_cards", ["user_id"], name: "index_gift_cards_on_user_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "stylist_id"
    t.integer  "user_id"
  end

  add_index "messages", ["stylist_id"], name: "index_messages_on_stylist_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.string   "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "stylist_id"
    t.integer  "user_id"
    t.integer  "booking_id"
  end

  add_index "notifications", ["booking_id"], name: "index_notifications_on_booking_id", using: :btree
  add_index "notifications", ["stylist_id"], name: "index_notifications_on_stylist_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "payout_infos", force: :cascade do |t|
    t.string   "legal_name"
    t.string   "business_name"
    t.string   "tax_id"
    t.string   "dob"
    t.string   "ssn"
    t.integer  "account_number"
    t.integer  "routing_number"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.integer  "zipcode"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "user_id"
  end

  add_index "payout_infos", ["user_id"], name: "index_payout_infos_on_user_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.text     "description"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "popular_services", force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "service_sub_category_id"
  end

  add_index "popular_services", ["service_sub_category_id"], name: "index_popular_services_on_service_sub_category_id", using: :btree

  create_table "previous_works", force: :cascade do |t|
    t.string   "description"
    t.string   "legend"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "user_id"
    t.boolean  "is_additional", default: false
  end

  add_index "previous_works", ["user_id"], name: "index_previous_works_on_user_id", using: :btree

  create_table "promo_codes", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "promo_code"
    t.date     "expiration"
    t.float    "discount_by_percentage"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "recently_bookeds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  add_index "recently_bookeds", ["user_id"], name: "index_recently_bookeds_on_user_id", using: :btree

  create_table "reviews", force: :cascade do |t|
    t.string   "comments"
    t.string   "quality"
    t.string   "professionalism"
    t.string   "timing"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "stylist_id"
    t.integer  "user_id"
    t.integer  "service_id"
    t.integer  "average_rating"
  end

  add_index "reviews", ["service_id"], name: "index_reviews_on_service_id", using: :btree
  add_index "reviews", ["stylist_id"], name: "index_reviews_on_stylist_id", using: :btree
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "is_deleted", default: false
  end

  create_table "service_sub_categories", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.float    "price"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "service_category_id"
  end

  add_index "service_sub_categories", ["service_category_id"], name: "index_service_sub_categories_on_service_category_id", using: :btree

  create_table "services", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "amount"
    t.decimal  "time"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "location"
    t.integer  "user_id"
    t.string   "location1"
    t.string   "location2"
    t.string   "location3"
    t.string   "location4"
    t.string   "location5"
    t.integer  "service_category_id"
    t.integer  "service_sub_category_id"
    t.boolean  "is_deleted",              default: false
  end

  add_index "services", ["service_category_id"], name: "index_services_on_service_category_id", using: :btree
  add_index "services", ["service_sub_category_id"], name: "index_services_on_service_sub_category_id", using: :btree
  add_index "services", ["user_id"], name: "index_services_on_user_id", using: :btree

  create_table "transactions", force: :cascade do |t|
    t.string   "braintree_transaction_id"
    t.string   "transaction_status"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "booking_id"
    t.boolean  "is_deleted",               default: false
    t.integer  "stylist_id"
    t.integer  "gift_card_id"
    t.string   "pay_via"
    t.string   "amount_paid"
  end

  add_index "transactions", ["booking_id"], name: "index_transactions_on_booking_id", using: :btree
  add_index "transactions", ["gift_card_id"], name: "index_transactions_on_gift_card_id", using: :btree
  add_index "transactions", ["stylist_id"], name: "index_transactions_on_stylist_id", using: :btree

  create_table "update_availabilities", force: :cascade do |t|
    t.date     "date"
    t.boolean  "is_not_available", default: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "user_id"
  end

  add_index "update_availabilities", ["user_id"], name: "index_update_availabilities_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.boolean  "admin"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "phone"
    t.string   "address"
    t.string   "brand"
    t.string   "braintree_customer_id"
    t.text     "description"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "pin"
    t.string   "zipcode"
    t.string   "stylist_type"
    t.string   "authentication_token"
    t.string   "marked"
    t.integer  "role_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "city"
    t.string   "state"
    t.text     "bio"
    t.boolean  "is_deleted",             default: false
    t.string   "gender"
    t.string   "apple_uuid"
    t.string   "address2"
    t.boolean  "verified_number",        default: false
    t.json     "notification_settings"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

  create_table "votes", force: :cascade do |t|
    t.boolean  "vote"
    t.integer  "votable_id"
    t.string   "votable_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id"
  end

  add_index "votes", ["user_id"], name: "index_votes_on_user_id", using: :btree

  add_foreign_key "availabilities", "users"
  add_foreign_key "bookings", "services"
  add_foreign_key "bookings", "users"
  add_foreign_key "favourite_stylists", "users"
  add_foreign_key "featured_professionals", "users"
  add_foreign_key "gift_cards", "users"
  add_foreign_key "messages", "users"
  add_foreign_key "notifications", "bookings"
  add_foreign_key "notifications", "users"
  add_foreign_key "payout_infos", "users"
  add_foreign_key "popular_services", "service_sub_categories"
  add_foreign_key "previous_works", "users"
  add_foreign_key "recently_bookeds", "users"
  add_foreign_key "reviews", "services"
  add_foreign_key "reviews", "users"
  add_foreign_key "service_sub_categories", "service_categories"
  add_foreign_key "services", "service_categories"
  add_foreign_key "services", "service_sub_categories"
  add_foreign_key "services", "users"
  add_foreign_key "transactions", "bookings"
  add_foreign_key "transactions", "gift_cards"
  add_foreign_key "update_availabilities", "users"
  add_foreign_key "users", "roles"
  add_foreign_key "votes", "users"
end
