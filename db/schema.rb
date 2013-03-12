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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130128132357) do

  create_table "admins", :force => true do |t|
    t.string   "email",               :default => "", :null => false
    t.string   "encrypted_password",  :default => "", :null => false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true

  create_table "categories", :force => true do |t|
    t.string "name"
  end

  add_index "categories", ["name"], :name => "idx_categories_on_name", :unique => true

  create_table "category_reviews", :force => true do |t|
    t.integer "category_id"
    t.integer "review_id"
  end

  create_table "email_invites", :force => true do |t|
    t.integer  "from_user_id"
    t.string   "token"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "email"
    t.string   "answer",       :default => "later"
  end

  add_index "email_invites", ["token"], :name => "index_email_invites_on_token"

  create_table "films", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "films_genres", :force => true do |t|
    t.integer "film_id"
    t.integer "genre_id"
  end

  create_table "films_users", :force => true do |t|
    t.integer  "film_id"
    t.integer  "user_id"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "films_users_genres", :force => true do |t|
    t.integer "film_user_id"
    t.integer "genre_id"
  end

  create_table "friend_relations", :force => true do |t|
    t.string  "provider"
    t.integer "source_user_id", :limit => 8
    t.integer "target_user_id", :limit => 8
    t.float   "distance",                    :default => 100000.0, :null => false
  end

  create_table "genres", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "genres", ["name"], :name => "idx_on_name", :unique => true

  create_table "reviews", :force => true do |t|
    t.integer  "user_id"
    t.integer  "author_id"
    t.string   "name",                                                         :null => false
    t.string   "phone"
    t.text     "comment"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.boolean  "visible",                                    :default => true
    t.string   "address"
    t.decimal  "lat",         :precision => 12, :scale => 9
    t.decimal  "lng",         :precision => 12, :scale => 9
    t.integer  "repost_from"
  end

  add_index "reviews", ["author_id"], :name => "index_reviews_on_author_id"
  add_index "reviews", ["user_id"], :name => "index_reviews_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                                               :default => "",    :null => false
    t.datetime "created_at",                                                                             :null => false
    t.datetime "updated_at",                                                                             :null => false
    t.string   "provider",               :limit => 20
    t.integer  "external_user_id",       :limit => 8
    t.string   "name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "encrypted_password",                                                  :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.text     "address"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.decimal  "lat",                                  :precision => 12, :scale => 9
    t.decimal  "lng",                                  :precision => 12, :scale => 9
    t.boolean  "address_visible",                                                     :default => false, :null => false
    t.string   "city"
    t.integer  "invites_count",                                                       :default => 0
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["provider", "external_user_id"], :name => "idx_on_provider_and_external_user_id", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
