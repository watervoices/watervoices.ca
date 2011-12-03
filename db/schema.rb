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

ActiveRecord::Schema.define(:version => 20111203205036) do

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
  end

  add_index "first_nations", ["tribal_council_id"], :name => "index_first_nations_on_tribal_council_id"

  create_table "nation_memberships", :force => true do |t|
    t.integer  "first_nation_id"
    t.integer  "reserve_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nation_memberships", ["first_nation_id"], :name => "index_nation_memberships_on_first_nation_id"
  add_index "nation_memberships", ["reserve_id"], :name => "index_nation_memberships_on_reserve_id"

  create_table "reserves", :force => true do |t|
    t.string   "name"
    t.integer  "number"
    t.string   "location"
    t.float    "hectares"
    t.string   "detail_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

end
