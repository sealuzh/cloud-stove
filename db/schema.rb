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

ActiveRecord::Schema.define(version: 20151130091706) do

  create_table "cloud_applications", force: :cascade do |t|
    t.string   "name"
    t.text     "more_attributes"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "components", force: :cascade do |t|
    t.string   "name"
    t.string   "component_type"
    t.text     "more_attributes"
    t.integer  "cloud_application_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "components", ["cloud_application_id"], name: "index_components_on_cloud_application_id"

  create_table "providers", force: :cascade do |t|
    t.string   "name"
    t.text     "more_attributes"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "resources", force: :cascade do |t|
    t.string   "name"
    t.text     "more_attributes"
    t.integer  "provider_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "resources", ["provider_id"], name: "index_resources_on_provider_id"

end