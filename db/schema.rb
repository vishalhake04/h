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

  create_table "availabilities", force: :cascade do |t|
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "time",       limit: 255
    t.boolean  "mon",                    default: false
    t.boolean  "tue",                    default: false
    t.boolean  "wed",                    default: false
    t.boolean  "thu",                    default: false
    t.boolean  "fri",                    default: false
    t.boolean  "sat",                    default: false
    t.boolean  "sun",                    default: false
    t.integer  "user_id",    limit: 4
  end

  add_index "availabilities", ["user_id"], name: "index_availabilities_on_user_id", using: :btree

  create_table "bookings", force: :cascade do |t|
    t.date     "dates"
    t.string   "slots",        limit: 255
    t.boolean  "is_confirmed",             default: false
    t.boolean  "is_deleted",               default: false
    t.string   "status",       limit: 255, default: ""
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "stylist_id",   limit: 4
    t.integer  "service_id",   limit: 4
    t.integer  "user_id",      limit: 4
    t.integer  "total_amount", limit: 4
    t.integer  "total_time",   limit: 4
  end

  add_index "bookings", ["service_id"], name: "index_bookings_on_service_id", using: :btree
  add_index "bookings", ["stylist_id"], name: "index_bookings_on_stylist_id", using: :btree
  add_index "bookings", ["user_id"], name: "index_bookings_on_user_id", using: :btree

  create_table "favourite_stylists", force: :cascade do |t|
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "stylist_id",  limit: 4
    t.integer  "user_id",     limit: 4
    t.boolean  "unfavourite",           default: false
  end

  add_index "favourite_stylists", ["stylist_id"], name: "index_favourite_stylists_on_stylist_id", using: :btree
  add_index "favourite_stylists", ["user_id"], name: "index_favourite_stylists_on_user_id", using: :btree

  create_table "featured_professionals", force: :cascade do |t|
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "user_id",    limit: 4
  end

  add_index "featured_professionals", ["user_id"], name: "index_featured_professionals_on_user_id", using: :btree

  create_table "gift_cards", force: :cascade do |t|
    t.string   "gift_code",        limit: 255
    t.string   "to_email",         limit: 255
    t.integer  "amount",           limit: 4
    t.string   "message",          limit: 255
    t.integer  "remaining_amount", limit: 4
    t.boolean  "is_valid",                     default: true
    t.date     "validity"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "user_id",          limit: 4
    t.integer  "gift_owner_id",    limit: 4
  end

  add_index "gift_cards", ["gift_owner_id"], name: "index_gift_cards_on_gift_owner_id", using: :btree
  add_index "gift_cards", ["user_id"], name: "index_gift_cards_on_user_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "message",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "stylist_id", limit: 4
    t.integer  "user_id",    limit: 4
  end

  add_index "messages", ["stylist_id"], name: "index_messages_on_stylist_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.string   "message",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "stylist_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.integer  "booking_id", limit: 4
  end

  add_index "notifications", ["booking_id"], name: "index_notifications_on_booking_id", using: :btree
  add_index "notifications", ["stylist_id"], name: "index_notifications_on_stylist_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "payout_infos", force: :cascade do |t|
    t.string   "legal_name",     limit: 255
    t.string   "business_name",  limit: 255
    t.string   "tax_id",         limit: 255
    t.string   "dob",            limit: 255
    t.string   "ssn",            limit: 255
    t.integer  "account_number", limit: 4
    t.integer  "routing_number", limit: 4
    t.string   "street_address", limit: 255
    t.string   "city",           limit: 255
    t.string   "state",          limit: 255
    t.integer  "zipcode",        limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "user_id",        limit: 4
  end

  add_index "payout_infos", ["user_id"], name: "index_payout_infos_on_user_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.text     "description",        limit: 65535
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.integer  "imageable_id",       limit: 4
    t.string   "imageable_type",     limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "popular_services", force: :cascade do |t|
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "service_sub_category_id", limit: 4
  end

  add_index "popular_services", ["service_sub_category_id"], name: "index_popular_services_on_service_sub_category_id", using: :btree

  create_table "previous_works", force: :cascade do |t|
    t.string   "description",   limit: 255
    t.string   "legend",        limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "user_id",       limit: 4
    t.boolean  "is_additional",             default: false
  end

  add_index "previous_works", ["user_id"], name: "index_previous_works_on_user_id", using: :btree

  create_table "promo_codes", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "description",            limit: 255
    t.string   "promo_code",             limit: 255
    t.date     "expiration"
    t.float    "discount_by_percentage", limit: 24
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "recently_bookeds", force: :cascade do |t|
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "user_id",    limit: 4
  end

  add_index "recently_bookeds", ["user_id"], name: "index_recently_bookeds_on_user_id", using: :btree

  create_table "reviews", force: :cascade do |t|
    t.string   "comments",        limit: 255
    t.string   "quality",         limit: 255
    t.string   "professionalism", limit: 255
    t.string   "timing",          limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "stylist_id",      limit: 4
    t.integer  "user_id",         limit: 4
    t.integer  "service_id",      limit: 4
    t.integer  "average_rating",  limit: 4
  end

  add_index "reviews", ["service_id"], name: "index_reviews_on_service_id", using: :btree
  add_index "reviews", ["stylist_id"], name: "index_reviews_on_stylist_id", using: :btree
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "service_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "is_deleted",             default: false
  end

  create_table "service_sub_categories", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "description",         limit: 255
    t.float    "price",               limit: 24
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "service_category_id", limit: 4
  end

  add_index "service_sub_categories", ["service_category_id"], name: "index_service_sub_categories_on_service_category_id", using: :btree

  create_table "services", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.string   "description",             limit: 255
    t.integer  "amount",                  limit: 4
    t.decimal  "time",                                precision: 10
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.string   "location",                limit: 255
    t.integer  "user_id",                 limit: 4
    t.string   "location1",               limit: 255
    t.string   "location2",               limit: 255
    t.string   "location3",               limit: 255
    t.string   "location4",               limit: 255
    t.string   "location5",               limit: 255
    t.integer  "service_category_id",     limit: 4
    t.integer  "service_sub_category_id", limit: 4
    t.boolean  "is_deleted",                                         default: false
  end

  add_index "services", ["service_category_id"], name: "index_services_on_service_category_id", using: :btree
  add_index "services", ["service_sub_category_id"], name: "index_services_on_service_sub_category_id", using: :btree
  add_index "services", ["user_id"], name: "index_services_on_user_id", using: :btree

  create_table "transactions", force: :cascade do |t|
    t.string   "braintree_transaction_id", limit: 255
    t.string   "transaction_status",       limit: 255
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "booking_id",               limit: 4
    t.boolean  "is_deleted",                           default: false
    t.integer  "stylist_id",               limit: 4
    t.integer  "gift_card_id",             limit: 4
    t.string   "pay_via",                  limit: 255
    t.string   "amount_paid",              limit: 255
  end

  add_index "transactions", ["booking_id"], name: "index_transactions_on_booking_id", using: :btree
  add_index "transactions", ["gift_card_id"], name: "index_transactions_on_gift_card_id", using: :btree
  add_index "transactions", ["stylist_id"], name: "index_transactions_on_stylist_id", using: :btree

  create_table "update_availabilities", force: :cascade do |t|
    t.boolean  "is_not_available",           default: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "user_id",          limit: 4
  end

  add_index "update_availabilities", ["user_id"], name: "index_update_availabilities_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,   default: "",    null: false
    t.string   "encrypted_password",     limit: 255,   default: "",    null: false
    t.boolean  "admin"
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "name",                   limit: 255
    t.string   "phone",                  limit: 255
    t.string   "address",                limit: 255
    t.string   "brand",                  limit: 255
    t.string   "braintree_customer_id",  limit: 255
    t.text     "description",            limit: 65535
    t.float    "latitude",               limit: 24
    t.float    "longitude",              limit: 24
    t.string   "pin",                    limit: 255
    t.string   "zipcode",                limit: 255
    t.string   "stylist_type",           limit: 255
    t.string   "authentication_token",   limit: 255
    t.string   "marked",                 limit: 255
    t.integer  "role_id",                limit: 4
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "city",                   limit: 255
    t.string   "state",                  limit: 255
    t.text     "bio",                    limit: 65535
    t.boolean  "is_deleted",                           default: false
    t.string   "gender",                 limit: 255
    t.string   "apple_uuid",             limit: 255
    t.string   "address2",               limit: 255
    t.boolean  "verified_number",                      default: false
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

  create_table "votes", force: :cascade do |t|
    t.boolean  "vote"
    t.integer  "votable_id",   limit: 4
    t.string   "votable_type", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "user_id",      limit: 4
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
