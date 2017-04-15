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

ActiveRecord::Schema.define(version: 20170415092520) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "geolocation_locations", force: :cascade do |t|
    t.inet   "ip_address"
    t.string "country_code"
    t.string "country"
    t.string "city"
    t.float  "latitude"
    t.float  "longitude"
    t.bigint "mystery_value"
    t.index ["country_code", "country", "city"], name: "index_geolocation_locations_on_cccc", unique: true, using: :btree
    t.index ["ip_address"], name: "index_geolocation_locations_on_ip_address", using: :btree
  end

end
