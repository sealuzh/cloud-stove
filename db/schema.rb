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

ActiveRecord::Schema.define(version: 20161009185011) do

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
    t.integer  "user_id"
  end

  add_index "constraints", ["ingredient_id"], name: "index_constraints_on_ingredient_id"
  add_index "constraints", ["source_id"], name: "index_constraints_on_source_id"
  add_index "constraints", ["target_id"], name: "index_constraints_on_target_id"

  create_table "cpu_workloads", force: :cascade do |t|
    t.integer  "cspu_user_capacity"
    t.float    "parallelism"
    t.integer  "ingredient_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "user_id"
  end

  add_index "cpu_workloads", ["ingredient_id"], name: "index_cpu_workloads_on_ingredient_id"

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
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "status"
    t.integer  "num_simultaneous_users"
    t.integer  "user_id"
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
    t.integer  "user_id"
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

  create_table "ram_workloads", force: :cascade do |t|
    t.integer  "ram_mb_required"
    t.float    "ram_mb_growth_per_user"
    t.integer  "ingredient_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "ram_mb_required_user_capacity"
    t.integer  "user_id"
  end

  add_index "ram_workloads", ["ingredient_id"], name: "index_ram_workloads_on_ingredient_id"

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
  add_index "resources", ["resource_code"], name: "index_resources_on_resource_code"

  create_table "traffic_workloads", force: :cascade do |t|
    t.integer  "visits_per_month"
    t.integer  "requests_per_visit"
    t.integer  "request_size_kb"
    t.integer  "ingredient_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "user_id"
  end

  add_index "traffic_workloads", ["ingredient_id"], name: "index_traffic_workloads_on_ingredient_id"

  create_table "user_workloads", force: :cascade do |t|
    t.integer  "num_simultaneous_users"
    t.integer  "ingredient_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id"
  end

  add_index "user_workloads", ["ingredient_id"], name: "index_user_workloads_on_ingredient_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin"
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.text     "tokens"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true

end
