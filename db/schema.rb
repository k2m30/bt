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

ActiveRecord::Schema.define(version: 20150807122725) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "records", id: false, force: :cascade do |t|
    t.inet     "client_ip"
    t.integer  "client_port"
    t.inet     "destination_ip"
    t.integer  "destination_port"
    t.datetime "session_start"
    t.datetime "session_end"
    t.integer  "bytes_sent"
    t.integer  "bytes_received"
    t.string   "url"
    t.string   "domain"
  end

  add_index "records", ["client_ip"], name: "index_records_on_client_ip", using: :btree
  add_index "records", ["destination_ip"], name: "index_records_on_destination_ip", using: :btree
  add_index "records", ["domain"], name: "index_records_on_domain", using: :btree

end
