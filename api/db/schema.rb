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

ActiveRecord::Schema.define(version: 20190327000000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "thinkspace_artifact_buckets", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "authable_id"
    t.string   "authable_type"
    t.text     "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_artifact_buckets", ["authable_id", "authable_type"], name: "idx_thinkspace_artifact_buckets_on_authable", using: :btree
  add_index "thinkspace_artifact_buckets", ["user_id"], name: "idx_thinkspace_artifact_buckets_on_user", using: :btree

  create_table "thinkspace_artifact_files", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "bucket_id"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_artifact_files", ["bucket_id"], name: "idx_thinkspace_artifact_files_on_bucket", using: :btree
  add_index "thinkspace_artifact_files", ["ownerable_id", "ownerable_type"], name: "idx_thinkspace_artifact_files_on_ownerable", using: :btree
  add_index "thinkspace_artifact_files", ["user_id"], name: "idx_thinkspace_artifact_files_on_user", using: :btree

  create_table "thinkspace_builder_templates", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "templateable_id"
    t.string   "templateable_type"
    t.boolean  "domain",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "value"
  end

  create_table "thinkspace_casespace_assignments", force: :cascade do |t|
    t.integer  "space_id"
    t.string   "title"
    t.string   "name"
    t.string   "bundle_type"
    t.text     "description"
    t.text     "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.json     "settings"
  end

  add_index "thinkspace_casespace_assignments", ["space_id"], name: "idx_thinkspace_casespace_assignments_on_space", using: :btree
  add_index "thinkspace_casespace_assignments", ["state"], name: "idx_thinkspace_casespace_assignments_on_state", using: :btree

  create_table "thinkspace_casespace_case_manager_templates", force: :cascade do |t|
    t.integer  "templateable_id"
    t.string   "templateable_type"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_casespace_phase_components", force: :cascade do |t|
    t.integer  "component_id"
    t.integer  "phase_id"
    t.integer  "componentable_id"
    t.string   "componentable_type"
    t.string   "section"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_casespace_phase_components", ["component_id"], name: "idx_thinkspace_casespace_phase_components_on_component", using: :btree
  add_index "thinkspace_casespace_phase_components", ["phase_id"], name: "idx_thinkspace_casespace_phase_components_on_phase", using: :btree

  create_table "thinkspace_casespace_phase_scores", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "phase_state_id"
    t.decimal  "score",          precision: 9, scale: 3
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_casespace_phase_scores", ["phase_state_id"], name: "idx_thinkspace_casespace_phase_scores_on_phase_state", using: :btree
  add_index "thinkspace_casespace_phase_scores", ["user_id"], name: "idx_thinkspace_casespace_phase_scores_on_user", using: :btree

  create_table "thinkspace_casespace_phase_states", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "phase_id"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
    t.string   "current_state"
    t.datetime "archived_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_casespace_phase_states", ["archived_at"], name: "idx_thinkspace_casespace_phase_states_on_archived", using: :btree
  add_index "thinkspace_casespace_phase_states", ["ownerable_id", "ownerable_type"], name: "idx_thinkspace_casespace_phase_states_on_ownerable", using: :btree
  add_index "thinkspace_casespace_phase_states", ["phase_id"], name: "idx_thinkspace_casespace_phase_states_on_phase", using: :btree
  add_index "thinkspace_casespace_phase_states", ["user_id"], name: "idx_thinkspace_casespace_phase_states_on_user", using: :btree

  create_table "thinkspace_casespace_phase_templates", force: :cascade do |t|
    t.string   "title"
    t.string   "name"
    t.string   "description"
    t.boolean  "domain",      default: false
    t.text     "template"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "value"
  end

  create_table "thinkspace_casespace_phases", force: :cascade do |t|
    t.integer  "assignment_id"
    t.integer  "phase_template_id"
    t.integer  "team_category_id"
    t.string   "title"
    t.text     "description"
    t.integer  "position"
    t.string   "default_state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.json     "settings"
  end

  add_index "thinkspace_casespace_phases", ["assignment_id"], name: "idx_thinkspace_casespace_phases_on_assignment", using: :btree
  add_index "thinkspace_casespace_phases", ["phase_template_id"], name: "idx_thinkspace_casespace_phases_on_phase_template", using: :btree
  add_index "thinkspace_casespace_phases", ["state"], name: "idx_thinkspace_casespace_phases_on_state", using: :btree

  create_table "thinkspace_common_agreements", force: :cascade do |t|
    t.string   "doc_type"
    t.datetime "effective_at"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_api_sessions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_common_api_sessions", ["user_id"], name: "idx_thinkspace_common_api_sessions_on_user", using: :btree

  create_table "thinkspace_common_components", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.json     "value"
    t.json     "preprocessors"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_common_components", ["title"], name: "idx_thinkspace_common_components_on_title", using: :btree

  create_table "thinkspace_common_configurations", force: :cascade do |t|
    t.integer  "configurable_id"
    t.string   "configurable_type"
    t.json     "settings",          default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_common_configurations", ["configurable_id", "configurable_type"], name: "idx_thinkspace_common_configurations_on_configurable", using: :btree

  create_table "thinkspace_common_disciplines", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_invitations", force: :cascade do |t|
    t.integer  "invitable_id"
    t.string   "invitable_type"
    t.integer  "user_id"
    t.integer  "sender_id"
    t.string   "role"
    t.string   "token"
    t.string   "email"
    t.string   "state"
    t.datetime "expires_at"
    t.datetime "accepted_at"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_keys", force: :cascade do |t|
    t.string   "key"
    t.string   "source"
    t.string   "category"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_common_keys", ["key"], name: "idx_thinkspace_common_keys", using: :btree

  create_table "thinkspace_common_password_resets", force: :cascade do |t|
    t.string   "token"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_space_space_types", force: :cascade do |t|
    t.integer  "space_id"
    t.integer  "space_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_common_space_space_types", ["space_id"], name: "idx_thinkspace_common_space_space_types_on_space", using: :btree
  add_index "thinkspace_common_space_space_types", ["space_type_id"], name: "idx_thinkspace_common_space_space_types_on_space_type", using: :btree

  create_table "thinkspace_common_space_types", force: :cascade do |t|
    t.string   "title"
    t.string   "lookup_model"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_space_users", force: :cascade do |t|
    t.integer  "space_id"
    t.integer  "user_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
  end

  add_index "thinkspace_common_space_users", ["space_id", "user_id"], name: "idx_thinkspace_common_space_users_on_space_user", using: :btree
  add_index "thinkspace_common_space_users", ["state"], name: "idx_thinkspace_common_space_users_on_state", using: :btree

  create_table "thinkspace_common_spaces", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
  end

  add_index "thinkspace_common_spaces", ["state"], name: "idx_thinkspace_common_spaces_on_state", using: :btree

  create_table "thinkspace_common_timetables", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "timeable_id"
    t.string   "timeable_type"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
    t.datetime "release_at"
    t.datetime "due_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "unlock_at"
    t.datetime "unlocked_at"
  end

  add_index "thinkspace_common_timetables", ["ownerable_id", "ownerable_type"], name: "idx_thinkspace_common_timetables_on_ownerable", using: :btree
  add_index "thinkspace_common_timetables", ["timeable_id", "timeable_type"], name: "idx_thinkspace_common_timetables_on_timeable", using: :btree

  create_table "thinkspace_common_user_disciplines", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "user_type"
    t.integer  "discipline_id"
    t.string   "discipline_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_user_keys", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "key_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_common_user_keys", ["user_id", "key_id"], name: "idx_thinkspace_common_user_keys_on_user", using: :btree

  create_table "thinkspace_common_users", force: :cascade do |t|
    t.integer  "oauth_user_id"
    t.string   "oauth_access_token"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",                 default: "",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.string   "activation_token"
    t.datetime "activated_at"
    t.datetime "activation_expires_at"
    t.integer  "parent_id"
    t.boolean  "superuser",             default: false
    t.datetime "last_sign_in_at"
    t.boolean  "email_optin",           default: true
    t.jsonb    "profile",               default: {}
    t.datetime "terms_accepted_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "thinkspace_common_users", ["email"], name: "idx_thinkspace_common_users_on_email", using: :btree
  add_index "thinkspace_common_users", ["parent_id"], name: "idx_thinkspace_common_users_on_parent_id", using: :btree

  create_table "thinkspace_diagnostic_path_path_items", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "path_id"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
    t.integer  "parent_id"
    t.integer  "path_itemable_id"
    t.string   "path_itemable_type"
    t.integer  "position"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "category"
  end

  add_index "thinkspace_diagnostic_path_path_items", ["ownerable_id", "ownerable_type"], name: "idx_thinkspace_diagnostic_path_path_items_on_ownerable", using: :btree
  add_index "thinkspace_diagnostic_path_path_items", ["path_id"], name: "idx_thinkspace_diagnostic_path_path_items_on_path", using: :btree

  create_table "thinkspace_diagnostic_path_paths", force: :cascade do |t|
    t.integer  "authable_id"
    t.string   "authable_type"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_diagnostic_path_paths", ["authable_id", "authable_type"], name: "idx_thinkspace_diagnostic_path_paths_on_authable", using: :btree

  create_table "thinkspace_diagnostic_path_viewer_viewers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "path_id"
    t.integer  "authable_id"
    t.string   "authable_type"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_diagnostic_path_viewer_viewers", ["authable_id", "authable_type"], name: "idx_thinkspace_diagnostic_path_viewer_viewers_on_authable", using: :btree
  add_index "thinkspace_diagnostic_path_viewer_viewers", ["ownerable_id", "ownerable_type"], name: "idx_thinkspace_diagnostic_path_viewer_viewers_on_ownerable", using: :btree
  add_index "thinkspace_diagnostic_path_viewer_viewers", ["path_id"], name: "idx_thinkspace_diagnostic_path_viewer_viewers_on_path", using: :btree

  create_table "thinkspace_html_contents", force: :cascade do |t|
    t.integer  "authable_id"
    t.string   "authable_type"
    t.text     "html_content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_html_contents", ["authable_id", "authable_type"], name: "idx_thinkspace_htmls_contents_on_authable", using: :btree

  create_table "thinkspace_importer_files", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "custom_url"
    t.string   "generated_model"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.json     "settings"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_importer_files", ["user_id"], name: "idx_thinkspace_importer_files_on_user", using: :btree

  create_table "thinkspace_indented_list_expert_responses", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "list_id"
    t.integer  "response_id"
    t.string   "state"
    t.json     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_indented_list_expert_responses", ["list_id"], name: "idx_thinkspace_indented_list_expert_responses_on_list", using: :btree
  add_index "thinkspace_indented_list_expert_responses", ["response_id"], name: "idx_thinkspace_indented_list_expert_responses_on_response", using: :btree
  add_index "thinkspace_indented_list_expert_responses", ["state"], name: "idx_thinkspace_indented_list_expert_responses_on_state", using: :btree

  create_table "thinkspace_indented_list_lists", force: :cascade do |t|
    t.integer  "authable_id"
    t.string   "authable_type"
    t.string   "title"
    t.boolean  "expert"
    t.json     "settings"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_indented_list_lists", ["authable_id", "authable_type"], name: "idx_thinkspace_indented_list_lists_on_authable", using: :btree
  add_index "thinkspace_indented_list_lists", ["expert"], name: "idx_thinkspace_indented_list_lists_on_expert", using: :btree

  create_table "thinkspace_indented_list_responses", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "list_id"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
    t.json     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_indented_list_responses", ["list_id"], name: "idx_thinkspace_indented_list_responses_on_list", using: :btree
  add_index "thinkspace_indented_list_responses", ["ownerable_id", "ownerable_type"], name: "idx_thinkspace_indented_list_responses_on_ownerable", using: :btree

  create_table "thinkspace_input_element_elements", force: :cascade do |t|
    t.integer  "componentable_id"
    t.string   "componentable_type"
    t.string   "name"
    t.string   "element_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_input_element_elements", ["componentable_id", "componentable_type"], name: "idx_thinkspace_input_elements_elements_on_componentable", using: :btree

  create_table "thinkspace_input_element_responses", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "element_id"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_input_element_responses", ["element_id"], name: "idx_thinkspace_input_elements_responses_on_element", using: :btree
  add_index "thinkspace_input_element_responses", ["ownerable_id", "ownerable_type"], name: "idx_thinkspace_input_elements_responses_on_ownerable", using: :btree
  add_index "thinkspace_input_element_responses", ["user_id"], name: "idx_thinkspace_input_elements_responses_on_user", using: :btree

  create_table "thinkspace_lab_categories", force: :cascade do |t|
    t.integer  "chart_id"
    t.string   "title"
    t.text     "description"
    t.integer  "position"
    t.json     "value"
    t.json     "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_lab_categories", ["chart_id"], name: "idx_thinkspace_labs_categories_on_chart", using: :btree

  create_table "thinkspace_lab_charts", force: :cascade do |t|
    t.integer  "authable_id"
    t.string   "authable_type"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_lab_charts", ["authable_id", "authable_type"], name: "idx_thinkspace_charts_on_authable", using: :btree

  create_table "thinkspace_lab_observations", force: :cascade do |t|
    t.integer  "result_id"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
    t.integer  "attempts",       default: 0
    t.boolean  "all_correct",    default: false
    t.string   "state"
    t.json     "value"
    t.json     "detail"
    t.json     "archive"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_lab_observations", ["ownerable_id", "ownerable_type"], name: "idx_thinkspace_labs_observations_on_ownerable", using: :btree
  add_index "thinkspace_lab_observations", ["result_id"], name: "idx_thinkspace_labs_observations_on_result", using: :btree

  create_table "thinkspace_lab_results", force: :cascade do |t|
    t.integer  "category_id"
    t.string   "title"
    t.integer  "position"
    t.integer  "max_attempts", default: 0
    t.json     "value"
    t.json     "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_lab_results", ["category_id"], name: "idx_thinkspace_labs_results_on_category", using: :btree

  create_table "thinkspace_markup_comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "commenterable_id"
    t.string   "commenterable_type"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "discussion_id"
    t.integer  "position"
  end

  add_index "thinkspace_markup_comments", ["commenterable_id", "commenterable_type"], name: "idx_thinkspace_markup_comments_on_commenterable", using: :btree
  add_index "thinkspace_markup_comments", ["user_id"], name: "idx_thinkspace_markup_comments_on_user", using: :btree

  create_table "thinkspace_markup_discussions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "authable_id"
    t.string   "authable_type"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
    t.integer  "creatorable_id"
    t.string   "creatorable_type"
    t.integer  "discussionable_id"
    t.string   "discussionable_type"
    t.json     "value",               default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_markup_discussions", ["authable_id", "authable_type"], name: "idx_thinkspace_markup_discussions_on_authable", using: :btree
  add_index "thinkspace_markup_discussions", ["creatorable_id", "creatorable_type"], name: "idx_thinkspace_markup_discussions_on_creatorable", using: :btree
  add_index "thinkspace_markup_discussions", ["discussionable_id", "discussionable_type"], name: "idx_thinkspace_markup_discussions_on_discussionable", using: :btree
  add_index "thinkspace_markup_discussions", ["ownerable_id", "ownerable_type"], name: "idx_thinkspace_markup_discussions_on_ownerable", using: :btree
  add_index "thinkspace_markup_discussions", ["user_id"], name: "idx_thinkspace_markup_discussions_on_user", using: :btree

  create_table "thinkspace_markup_libraries", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_markup_library_comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "library_id"
    t.text     "comment"
    t.integer  "uses"
    t.date     "last_used"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "library_comment_id"
  end

  create_table "thinkspace_observation_list_group_lists", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_observation_list_group_lists", ["group_id"], name: "idx_thinkspace_observation_list_group_lists_on_group", using: :btree
  add_index "thinkspace_observation_list_group_lists", ["list_id"], name: "idx_thinkspace_observation_list_group_lists_on_list", using: :btree

  create_table "thinkspace_observation_list_groups", force: :cascade do |t|
    t.integer  "groupable_id"
    t.string   "groupable_type"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_observation_list_groups", ["groupable_id", "groupable_type"], name: "idx_thinkspace_observation_list_groups_on_groupable", using: :btree

  create_table "thinkspace_observation_list_lists", force: :cascade do |t|
    t.integer  "authable_id"
    t.string   "authable_type"
    t.json     "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_observation_list_lists", ["authable_id", "authable_type"], name: "idx_thinkspace_observation_list_lists_on_authable", using: :btree

  create_table "thinkspace_observation_list_observation_notes", force: :cascade do |t|
    t.integer  "observation_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_observation_list_observation_notes", ["observation_id"], name: "idx_thinkspace_observation_list_observation_notes_on_obs", using: :btree

  create_table "thinkspace_observation_list_observations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "list_id"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
    t.integer  "position"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_observation_list_observations", ["list_id"], name: "idx_thinkspace_observation_list_observations_on_list", using: :btree
  add_index "thinkspace_observation_list_observations", ["ownerable_id", "ownerable_type"], name: "idx_thinkspace_observation_list_observations_on_ownerable", using: :btree
  add_index "thinkspace_observation_list_observations", ["user_id"], name: "idx_thinkspace_observation_list_observations_on_user", using: :btree

  create_table "thinkspace_peer_assessment_assessments", force: :cascade do |t|
    t.integer  "authable_id"
    t.string   "authable_type"
    t.string   "state"
    t.json     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_peer_assessment_overviews", force: :cascade do |t|
    t.integer  "authable_id"
    t.string   "authable_type"
    t.integer  "assessment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_peer_assessment_review_sets", force: :cascade do |t|
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
    t.integer  "team_set_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_peer_assessment_reviews", force: :cascade do |t|
    t.string   "state"
    t.json     "value"
    t.integer  "reviewable_id"
    t.string   "reviewable_type"
    t.integer  "review_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_peer_assessment_team_sets", force: :cascade do |t|
    t.integer  "assessment_id"
    t.integer  "team_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_pub_sub_server_events", force: :cascade do |t|
    t.integer  "authable_id"
    t.string   "authable_type"
    t.integer  "user_id"
    t.string   "state"
    t.string   "origin"
    t.string   "channel"
    t.string   "event"
    t.string   "room_event"
    t.jsonb    "rooms"
    t.json     "value"
    t.json     "records"
    t.json     "timer_settings"
    t.datetime "timer_start_at"
    t.datetime "timer_end_at"
    t.datetime "timer_cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_pub_sub_server_events", ["authable_id", "authable_type"], name: "idx_thinkspace_pub_sub_server_events_on_authable", using: :btree
  add_index "thinkspace_pub_sub_server_events", ["channel"], name: "idx_thinkspace_pub_sub_server_events_on_channel", using: :btree
  add_index "thinkspace_pub_sub_server_events", ["created_at"], name: "idx_thinkspace_pub_sub_server_events_on_created_at", using: :btree
  add_index "thinkspace_pub_sub_server_events", ["event"], name: "idx_thinkspace_pub_sub_server_events_on_event", using: :btree
  add_index "thinkspace_pub_sub_server_events", ["room_event"], name: "idx_thinkspace_pub_sub_server_events_on_room_event", using: :btree
  add_index "thinkspace_pub_sub_server_events", ["rooms"], name: "idx_thinkspace_pub_sub_server_events_on_rooms", using: :gin
  add_index "thinkspace_pub_sub_server_events", ["state"], name: "idx_thinkspace_pub_sub_server_events_on_state", using: :btree
  add_index "thinkspace_pub_sub_server_events", ["timer_end_at"], name: "idx_thinkspace_pub_sub_server_events_on_end_at", using: :btree
  add_index "thinkspace_pub_sub_server_events", ["user_id"], name: "idx_thinkspace_pub_sub_server_events_on_user", using: :btree

  create_table "thinkspace_reporter_files", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "report_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_reporter_files", ["user_id"], name: "idx_thinkspace_reporter_files_on_user", using: :btree

  create_table "thinkspace_reporter_report_tokens", force: :cascade do |t|
    t.string   "token"
    t.datetime "expires_at"
    t.integer  "report_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_reporter_report_tokens", ["report_id"], name: "idx_thinkspace_reporter_report_tokens_on_report", using: :btree
  add_index "thinkspace_reporter_report_tokens", ["token"], name: "idx_thinkspace_reporter_report_tokens_on_token", using: :btree
  add_index "thinkspace_reporter_report_tokens", ["user_id"], name: "idx_thinkspace_reporter_report_tokens_on_user", using: :btree

  create_table "thinkspace_reporter_reports", force: :cascade do |t|
    t.string   "title"
    t.integer  "user_id"
    t.integer  "authable_id"
    t.string   "authable_type"
    t.json     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_reporter_reports", ["authable_type", "authable_id"], name: "idx_thinkspace_reporter_reports_on_authable", using: :btree
  add_index "thinkspace_reporter_reports", ["user_id"], name: "idx_thinkspace_reporter_reports_on_user", using: :btree

  create_table "thinkspace_resource_file_tags", force: :cascade do |t|
    t.integer  "file_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_resource_file_tags", ["file_id"], name: "idx_thinkspace_resource_file_tags_on_file", using: :btree
  add_index "thinkspace_resource_file_tags", ["tag_id"], name: "idx_thinkspace_resource_file_tags_on_tag", using: :btree

  create_table "thinkspace_resource_files", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "resourceable_id"
    t.string   "resourceable_type"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_fingerprint"
  end

  add_index "thinkspace_resource_files", ["resourceable_id", "resourceable_type"], name: "idx_thinkspace_resource_files_on_resourceable", using: :btree
  add_index "thinkspace_resource_files", ["user_id"], name: "idx_thinkspace_resource_files_on_user", using: :btree

  create_table "thinkspace_resource_link_tags", force: :cascade do |t|
    t.integer  "link_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_resource_link_tags", ["link_id"], name: "idx_thinkspace_resource_link_tags_on_link", using: :btree
  add_index "thinkspace_resource_link_tags", ["tag_id"], name: "idx_thinkspace_resource_link_tags_on_tag", using: :btree

  create_table "thinkspace_resource_links", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "resourceable_id"
    t.string   "resourceable_type"
    t.string   "title"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_resource_links", ["resourceable_id", "resourceable_type"], name: "idx_thinkspace_resource_links_on_resourceable", using: :btree
  add_index "thinkspace_resource_links", ["user_id"], name: "idx_thinkspace_resource_links_on_user", using: :btree

  create_table "thinkspace_resource_tags", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_resource_tags", ["taggable_id", "taggable_type"], name: "idx_thinkspace_resource_tags_on_taggable", using: :btree
  add_index "thinkspace_resource_tags", ["user_id"], name: "idx_thinkspace_resource_tags_on_user", using: :btree

  create_table "thinkspace_simulation_simulations", force: :cascade do |t|
    t.string   "title"
    t.integer  "authable_id"
    t.string   "authable_type"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_team_team_categories", force: :cascade do |t|
    t.string   "title"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_team_team_categories", ["category"], name: "idx_thinkspace_team_team_categories_on_category", using: :btree

  create_table "thinkspace_team_team_set_teamables", force: :cascade do |t|
    t.integer  "team_set_id"
    t.integer  "teamable_id"
    t.string   "teamable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_team_team_set_teamables", ["team_set_id"], name: "idx_thinkspace_team_team_set_teamables_on_team_set", using: :btree
  add_index "thinkspace_team_team_set_teamables", ["teamable_id", "teamable_type"], name: "idx_thinkspace_team_team_set_teamables_on_teamable", using: :btree

  create_table "thinkspace_team_team_sets", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "space_id"
    t.integer  "user_id"
    t.boolean  "default"
    t.json     "settings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
  end

  add_index "thinkspace_team_team_sets", ["space_id"], name: "idx_thinkspace_team_team_sets_on_space", using: :btree

  create_table "thinkspace_team_team_teamables", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "teamable_id"
    t.string   "teamable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_team_team_teamables", ["team_id"], name: "idx_thinkspace_team_team_teamables_on_team", using: :btree
  add_index "thinkspace_team_team_teamables", ["teamable_id", "teamable_type"], name: "idx_thinkspace_team_team_teamables_on_teamable", using: :btree

  create_table "thinkspace_team_team_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_team_team_users", ["user_id", "team_id"], name: "idx_thinkspace_team_team_users_on_user_team", using: :btree

  create_table "thinkspace_team_team_viewers", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "viewerable_id"
    t.string   "viewerable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_team_team_viewers", ["team_id"], name: "idx_thinkspace_team_team_viewers_on_team", using: :btree
  add_index "thinkspace_team_team_viewers", ["viewerable_id", "viewerable_type"], name: "idx_thinkspace_team_team_viewers_on_viewerable", using: :btree

  create_table "thinkspace_team_teams", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "color"
    t.string   "state"
    t.integer  "authable_id"
    t.string   "authable_type"
    t.integer  "team_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_team_teams", ["authable_id", "authable_type"], name: "idx_thinkspace_team_teams_on_authable", using: :btree

  create_table "thinkspace_weather_forecaster_assessment_items", force: :cascade do |t|
    t.integer  "item_id"
    t.integer  "assessment_id"
    t.string   "title"
    t.text     "description"
    t.text     "item_header"
    t.text     "presentation"
    t.json     "processing"
    t.json     "help_tip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_weather_forecaster_assessment_items", ["assessment_id"], name: "idx_thinkspace_weather_forecaster_asmt_items_on_asmt", using: :btree
  add_index "thinkspace_weather_forecaster_assessment_items", ["item_id"], name: "idx_thinkspace_weather_forecaster_asmt_items_on_item", using: :btree

  create_table "thinkspace_weather_forecaster_assessments", force: :cascade do |t|
    t.integer  "station_id"
    t.integer  "authable_id"
    t.string   "authable_type"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_weather_forecaster_assessments", ["authable_id", "authable_type"], name: "idx_thinkspace_weather_forecaster_assessments_on_authable", using: :btree
  add_index "thinkspace_weather_forecaster_assessments", ["station_id"], name: "idx_thinkspace_weather_forecaster_assessments_on_station", using: :btree

  create_table "thinkspace_weather_forecaster_forecast_day_actuals", force: :cascade do |t|
    t.integer  "forecast_day_id"
    t.integer  "station_id"
    t.json     "value"
    t.text     "original"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_weather_forecaster_forecast_day_actuals", ["forecast_day_id"], name: "idx_thinkspace_weather_forecaster_forecast_da_on_day", using: :btree
  add_index "thinkspace_weather_forecaster_forecast_day_actuals", ["station_id"], name: "idx_thinkspace_weather_forecaster_forecast_da_on_station", using: :btree

  create_table "thinkspace_weather_forecaster_forecast_days", force: :cascade do |t|
    t.datetime "forecast_at"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_weather_forecaster_forecast_days", ["forecast_at"], name: "idx_thinkspace_weather_forecaster_forecast_days_on_forecast_at", using: :btree

  create_table "thinkspace_weather_forecaster_forecasts", force: :cascade do |t|
    t.integer  "forecast_day_id"
    t.integer  "assessment_id"
    t.integer  "user_id"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
    t.decimal  "score",           precision: 9, scale: 2, default: 0.0
    t.integer  "attempts",                                default: 0
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_weather_forecaster_forecasts", ["assessment_id"], name: "idx_thinkspace_weather_forecaster_forecasts_on_assessment", using: :btree
  add_index "thinkspace_weather_forecaster_forecasts", ["forecast_day_id"], name: "idx_thinkspace_weather_forecaster_forecasts_on_day", using: :btree
  add_index "thinkspace_weather_forecaster_forecasts", ["ownerable_id", "ownerable_type"], name: "idx_thinkspace_weather_forecaster_forecasts_on_ownerable", using: :btree

  create_table "thinkspace_weather_forecaster_items", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.string   "score_var"
    t.text     "description"
    t.text     "item_header"
    t.text     "presentation"
    t.json     "response_metadata"
    t.json     "processing"
    t.json     "help_tip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_weather_forecaster_response_scores", force: :cascade do |t|
    t.integer  "response_id"
    t.decimal  "score",       precision: 9, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_weather_forecaster_response_scores", ["response_id"], name: "idx_thinkspace_weather_forecaster_response_scores_on_response", using: :btree

  create_table "thinkspace_weather_forecaster_responses", force: :cascade do |t|
    t.integer  "forecast_id"
    t.integer  "assessment_item_id"
    t.json     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_weather_forecaster_responses", ["assessment_item_id"], name: "idx_thinkspace_weather_forecaster_responses_on_asmt_item", using: :btree
  add_index "thinkspace_weather_forecaster_responses", ["forecast_id"], name: "idx_thinkspace_weather_forecaster_responses_on_forecast", using: :btree

  create_table "thinkspace_weather_forecaster_stations", force: :cascade do |t|
    t.string   "location"
    t.string   "block_number"
    t.string   "station_number"
    t.string   "place"
    t.string   "country"
    t.string   "region"
    t.string   "state"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_weather_forecaster_stations", ["location"], name: "idx_thinkspace_weather_forecaster_stations_on_location", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
