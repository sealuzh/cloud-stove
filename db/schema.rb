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

ActiveRecord::Schema.define(version: 20160211224629) do

  create_table "application_deployment_recommendations", force: :cascade do |t|
    t.text     "more_attributes",      default: "{}", null: false
    t.integer  "cloud_application_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "application_deployment_recommendations", ["cloud_application_id"], name: "index_app_dep_rec_on_cloud_app_id"

  create_table "blueprints", force: :cascade do |t|
    t.string   "name"
    t.text     "more_attributes", default: "{}", null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "cloud_applications", force: :cascade do |t|
    t.string   "name"
    t.text     "more_attributes", default: "{}", null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "blueprint_id"
  end

  add_index "cloud_applications", ["blueprint_id"], name: "index_cloud_applications_on_blueprint_id"

  create_table "components", force: :cascade do |t|
    t.string   "name"
    t.string   "component_type"
    t.text     "more_attributes", default: "{}", null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "blueprint_id"
  end

  add_index "components", ["blueprint_id"], name: "index_components_on_blueprint_id"

  create_table "concrete_components", force: :cascade do |t|
    t.string   "name"
    t.text     "more_attributes",      default: "{}", null: false
    t.integer  "component_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "cloud_application_id"
  end

  add_index "concrete_components", ["cloud_application_id"], name: "index_concrete_components_on_cloud_application_id"
  add_index "concrete_components", ["component_id"], name: "index_concrete_components_on_component_id"

  create_table "deployment_rules", force: :cascade do |t|
    t.text     "more_attributes"
    t.integer  "component_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "deployment_rules", ["component_id"], name: "index_deployment_rules_on_component_id"

  create_table "providers", force: :cascade do |t|
    t.string   "name"
    t.text     "more_attributes", default: "{}", null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "resources", force: :cascade do |t|
    t.string   "name"
    t.text     "more_attributes", default: "{}", null: false
    t.integer  "provider_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "resources", ["provider_id"], name: "index_resources_on_provider_id"

  create_table "slo_sets", force: :cascade do |t|
    t.text     "more_attributes",       default: "{}", null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "concrete_component_id"
  end

  add_index "slo_sets", ["concrete_component_id"], name: "index_slo_sets_on_concrete_component_id"

end
