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

ActiveRecord::Schema.define(version: 20160811141022) do

  create_table "constraints", force: :cascade do |t|
    t.integer  "ingredient_id"
    t.text     "more_attributes"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "type"
    t.integer  "source_id"
    t.integer  "target_id"
    t.integer  "min_ram"
    t.integer  "min_cpus"
    t.string   "preferred_region_area"
    t.string   "preferred_providers"
  end

  add_index "constraints", ["ingredient_id"], name: "index_constraints_on_ingredient_id"
  add_index "constraints", ["source_id"], name: "index_constraints_on_source_id"
  add_index "constraints", ["target_id"], name: "index_constraints_on_target_id"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "deployment_recommendations", force: :cascade do |t|
    t.text     "more_attributes"
    t.text     "ingredients_data"
    t.text     "resources_data"
    t.integer  "ingredient_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "status"
  end

  add_index "deployment_recommendations", ["ingredient_id"], name: "index_deployment_recommendations_on_ingredient_id"

  create_table "ingredients", force: :cascade do |t|
    t.string   "name"
    t.text     "body"
    t.text     "more_attributes"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "parent_id"
    t.integer  "template_id"
    t.boolean  "is_template",     default: false
  end

  add_index "ingredients", ["is_template"], name: "index_ingredients_on_is_template"
  add_index "ingredients", ["parent_id"], name: "index_ingredients_on_parent_id"
  add_index "ingredients", ["template_id"], name: "index_ingredients_on_template_id"

  create_table "providers", force: :cascade do |t|
    t.string   "name"
    t.text     "more_attributes", default: "{}", null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "resources", force: :cascade do |t|
    t.string   "name"
    t.text     "more_attributes",           default: "{}", null: false
    t.integer  "provider_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "resource_type"
    t.string   "region"
    t.integer  "region_code",     limit: 8
    t.string   "region_area"
    t.integer  "resource_code",   limit: 8
  end

  add_index "resources", ["provider_id"], name: "index_resources_on_provider_id"

  create_table "workloads", force: :cascade do |t|
    t.integer  "cpu_level"
    t.integer  "ram_level"
    t.integer  "baseline_num_users"
    t.integer  "requests_per_user"
    t.integer  "request_size_kb"
    t.integer  "ingredient_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "workloads", ["ingredient_id"], name: "index_workloads_on_ingredient_id"

end
