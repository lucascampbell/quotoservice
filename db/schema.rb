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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130409180439) do

  create_table "apn_apps", :force => true do |t|
    t.text     "apn_dev_cert"
    t.text     "apn_prod_cert"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "apn_device_groupings", :force => true do |t|
    t.integer "group_id"
    t.integer "device_id"
  end

  add_index "apn_device_groupings", ["device_id"], :name => "index_apn_device_groupings_on_device_id"
  add_index "apn_device_groupings", ["group_id", "device_id"], :name => "index_apn_device_groupings_on_group_id_and_device_id"
  add_index "apn_device_groupings", ["group_id"], :name => "index_apn_device_groupings_on_group_id"

  create_table "apn_devices", :force => true do |t|
    t.string   "token",              :null => false
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.datetime "last_registered_at"
    t.integer  "app_id"
  end

  add_index "apn_devices", ["token"], :name => "index_apn_devices_on_token"

  create_table "apn_group_notifications", :force => true do |t|
    t.integer  "group_id",          :null => false
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.text     "custom_properties"
    t.datetime "sent_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "apn_group_notifications", ["group_id"], :name => "index_apn_group_notifications_on_group_id"

  create_table "apn_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "app_id"
  end

  create_table "apn_notifications", :force => true do |t|
    t.integer  "device_id",                        :null => false
    t.integer  "errors_nb",         :default => 0
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.datetime "sent_at"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.text     "custom_properties"
  end

  add_index "apn_notifications", ["device_id"], :name => "index_apn_notifications_on_device_id"

  create_table "apn_pull_notifications", :force => true do |t|
    t.integer  "app_id"
    t.string   "title"
    t.string   "content"
    t.string   "link"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.boolean  "launch_notification"
  end

  create_table "c2dm_devices", :force => true do |t|
    t.string   "registration_id",    :null => false
    t.integer  "group_id"
    t.datetime "last_registered_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "c2dm_devices", ["registration_id"], :name => "index_c2dm_devices_on_registration_id", :unique => true

  create_table "c2dm_notifications", :force => true do |t|
    t.integer  "device_id",        :null => false
    t.string   "collapse_key",     :null => false
    t.text     "data"
    t.boolean  "delay_while_idle"
    t.datetime "sent_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "c2dm_notifications", ["device_id"], :name => "index_c2dm_notifications_on_device_id"

  create_table "comments", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "images", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "description"
    t.boolean  "active",           :default => false
    t.datetime "approved_at"
    t.string   "s3_link"
    t.string   "location"
    t.boolean  "device_submitted", :default => false
    t.string   "device_name"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "images_tags", :id => false, :force => true do |t|
    t.integer "image_id"
    t.integer "tag_id"
  end

  create_table "notes", :force => true do |t|
    t.text     "description"
    t.integer  "quote_id",    :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "notes", ["quote_id"], :name => "index_notes_on_quote_id"

  create_table "pushes", :force => true do |t|
    t.integer  "device_id"
    t.string   "platform"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "quote_creates", :force => true do |t|
    t.integer  "quote_id",                    :null => false
    t.string   "active",     :default => "f"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "version"
  end

  create_table "quote_deletes", :force => true do |t|
    t.integer  "quote_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "version"
  end

  create_table "quote_updates", :force => true do |t|
    t.text     "quote"
    t.integer  "quote_id"
    t.string   "abbreviation"
    t.string   "author"
    t.string   "translation"
    t.string   "rating"
    t.boolean  "active"
    t.string   "tags"
    t.string   "topics"
    t.string   "citation"
    t.string   "book"
    t.boolean  "favorite"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "quotes", :force => true do |t|
    t.text     "quote"
    t.string   "citation"
    t.string   "book"
    t.boolean  "favorite"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.boolean  "active",       :default => false
    t.string   "abbreviation"
    t.string   "translation"
    t.integer  "rating"
    t.string   "author"
    t.text     "quote_push"
    t.integer  "order_index"
  end

  create_table "quotes_tags", :id => false, :force => true do |t|
    t.integer "quote_id"
    t.integer "tag_id"
  end

  create_table "quotes_topics", :id => false, :force => true do |t|
    t.integer "quote_id"
    t.integer "topic_id"
  end

  create_table "tag_creates", :force => true do |t|
    t.integer  "tag_id",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tag_deletes", :force => true do |t|
    t.integer  "tag_id",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "visible",    :default => 0
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "topic_creates", :force => true do |t|
    t.integer  "topic_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "topic_deletes", :force => true do |t|
    t.integer  "topic_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.integer  "visible",     :default => 0
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.datetime "expires_at"
    t.string   "status"
    t.integer  "order_index"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
