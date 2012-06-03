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

ActiveRecord::Schema.define(:version => 20120603141756) do

  create_table "addresses", :force => true do |t|
    t.string   "kind"
    t.string   "address"
    t.string   "city"
    t.string   "region"
    t.string   "postal_code"
    t.string   "tel"
    t.string   "fax"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addressings", :force => true do |t|
    t.integer  "member_of_parliament_id"
    t.integer  "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addressings", ["address_id"], :name => "index_addressings_on_address_id"
  add_index "addressings", ["member_of_parliament_id"], :name => "index_addressings_on_member_of_parliament_id"

  create_table "data_rows", :force => true do |t|
    t.string   "table"
    t.text     "data"
    t.integer  "first_nation_id"
    t.integer  "reserve_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "data_rows", ["first_nation_id"], :name => "index_data_rows_on_first_nation_id"
  add_index "data_rows", ["reserve_id"], :name => "index_data_rows_on_reserve_id"

  create_table "first_nations", :force => true do |t|
    t.string   "name"
    t.integer  "number"
    t.string   "address"
    t.string   "postal_code"
    t.string   "phone"
    t.string   "fax"
    t.string   "url"
    t.string   "aboriginal_canada_portal"
    t.integer  "tribal_council_id"
    t.string   "detail_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "membership_authority"
    t.string   "election_system"
    t.integer  "quorum"
    t.string   "wikipedia"
  end

  add_index "first_nations", ["number"], :name => "index_first_nations_on_number"
  add_index "first_nations", ["tribal_council_id"], :name => "index_first_nations_on_tribal_council_id"

  create_table "member_of_parliaments", :force => true do |t|
    t.string   "caucus"
    t.string   "email"
    t.string   "web"
    t.string   "preferred_language"
    t.string   "twitter"
    t.string   "constituency"
    t.string   "constituency_number"
    t.string   "photo_url"
    t.string   "detail_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "member_of_parliaments", ["constituency"], :name => "index_member_of_parliaments_on_constituency"

  create_table "messages", :force => true do |t|
    t.text     "text"
    t.string   "from"
    t.string   "from_id"
    t.string   "network"
    t.integer  "reserve_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["reserve_id"], :name => "index_messages_on_reserve_id"

  create_table "nation_memberships", :force => true do |t|
    t.integer  "first_nation_id"
    t.integer  "reserve_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nation_memberships", ["first_nation_id", "reserve_id"], :name => "index_nation_memberships_on_first_nation_id_and_reserve_id"
  add_index "nation_memberships", ["first_nation_id"], :name => "index_nation_memberships_on_first_nation_id"
  add_index "nation_memberships", ["reserve_id"], :name => "index_nation_memberships_on_reserve_id"

  create_table "officials", :force => true do |t|
    t.string   "title"
    t.string   "surname"
    t.string   "given_name"
    t.date     "appointed_on"
    t.date     "expires_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "first_nation_id"
  end

  add_index "officials", ["given_name", "surname", "first_nation_id"], :name => "index_officials_on_given_name_and_surname_and_first_nation_id"

  create_table "reports", :force => true do |t|
    t.integer  "reserve_id"
    t.string   "title"
    t.integer  "status"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reports", ["reserve_id"], :name => "index_reports_on_reserve_id"

  create_table "reserves", :force => true do |t|
    t.string   "name"
    t.integer  "number"
    t.string   "location"
    t.float    "hectares"
    t.string   "detail_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "statcan_url"
    t.float    "latitude"
    t.float    "longitude"
    t.text     "connectivity"
    t.string   "connectivity_url"
    t.integer  "member_of_parliament_id"
    t.string   "fingerprint"
  end

  add_index "reserves", ["name"], :name => "index_reserves_on_name"
  add_index "reserves", ["number"], :name => "index_reserves_on_number"

  create_table "tribal_councils", :force => true do |t|
    t.string   "name"
    t.string   "operating_name"
    t.integer  "number"
    t.string   "address"
    t.string   "city"
    t.string   "postal_code"
    t.string   "country"
    t.integer  "geographic_zone"
    t.string   "environmental_index"
    t.string   "detail_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
  end

  add_index "tribal_councils", ["number"], :name => "index_tribal_councils_on_number"

end
