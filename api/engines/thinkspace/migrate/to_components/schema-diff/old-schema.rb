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

ActiveRecord::Schema.define(version: 20150526186022) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: true do |t|
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

  create_table "thinkspace_comment_comments", force: true do |t|
    t.integer  "owner_id"
    t.integer  "user_id"
    t.string   "comment_type"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_comment_comments", ["commentable_id", "commentable_type"], name: "idx_ts_comments_on_commentable", using: :btree
  add_index "thinkspace_comment_comments", ["commentable_type"], name: "idx_ts_comments_on_comment_type", using: :btree

  create_table "thinkspace_common_configurations", force: true do |t|
    t.integer  "configurable_id"
    t.string   "configurable_type"
    t.json     "settings",          default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_helpers", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "association_name"
    t.string   "default_view_generator"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_space_space_types", force: true do |t|
    t.integer  "space_type_id"
    t.integer  "space_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_space_types", force: true do |t|
    t.string   "title"
    t.string   "lookup_model"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_space_users", force: true do |t|
    t.integer  "space_id"
    t.integer  "user_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_common_space_users", ["space_id", "user_id"], name: "idx_ts_common_space_users_space_user_id", using: :btree

  create_table "thinkspace_common_spaces", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_tools", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "default_view_generator"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_user_invitations", force: true do |t|
    t.integer  "user_id"
    t.text     "settings"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_common_users", force: true do |t|
    t.integer  "oauth_user_id"
    t.string   "oauth_access_token"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",                default: "", null: false
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_importer_files", force: true do |t|
    t.integer  "user_id"
    t.string   "custom_url"
    t.string   "generated_model"
    t.json     "settings"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_markup_comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "commenterable_id"
    t.string   "commenterable_type"
    t.integer  "authable_id"
    t.string   "authable_type"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "top"
    t.integer  "commentable_id"
    t.string   "commentable_type"
  end

  add_index "thinkspace_markup_comments", ["commenterable_id", "commenterable_type"], name: "idx_ts_markup_on_commenterable", using: :btree
  add_index "thinkspace_markup_comments", ["ownerable_id", "ownerable_type"], name: "idx_ts_markup_on_ownerable", using: :btree

  create_table "thinkspace_resources_file_tags", force: true do |t|
    t.integer  "file_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_resources_files", force: true do |t|
    t.integer  "resourceable_id"
    t.string   "resourceable_type"
    t.integer  "user_id"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_resources_link_tags", force: true do |t|
    t.integer  "link_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_resources_links", force: true do |t|
    t.string   "title"
    t.string   "url"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resourceable_id"
    t.string   "resourceable_type"
  end

  create_table "thinkspace_resources_tags", force: true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_team_categories", force: true do |t|
    t.string   "title"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_team_team_teamables", force: true do |t|
    t.integer  "team_id"
    t.integer  "teamable_id"
    t.string   "teamable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_team_team_teamables", ["team_id"], name: "idx_ts_team_team_teamables_on_team", using: :btree
  add_index "thinkspace_team_team_teamables", ["teamable_id", "teamable_type"], name: "idx_ts_team_team_teamables_on_teamable", using: :btree

  create_table "thinkspace_team_team_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_team_team_users", ["user_id", "team_id"], name: "idx_ts_team_users_on_user_id_team_id", using: :btree

  create_table "thinkspace_team_team_viewers", force: true do |t|
    t.integer  "team_id"
    t.integer  "viewerable_id"
    t.string   "viewerable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_team_team_viewers", ["team_id"], name: "idx_ts_team_team_viewers_on_team", using: :btree
  add_index "thinkspace_team_team_viewers", ["viewerable_id", "viewerable_type"], name: "idx_ts_team_team_viewers_on_viewerable", using: :btree

  create_table "thinkspace_team_teams", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authable_id"
    t.string   "authable_type"
  end

  add_index "thinkspace_team_teams", ["authable_id", "authable_type"], name: "idx_ts_team_teams_on_authable", using: :btree
  add_index "thinkspace_team_teams", ["category_id"], name: "idx_ts_team_teams_on_category", using: :btree

  create_table "thinkspace_tools_artifact_buckets", force: true do |t|
    t.integer  "user_id"
    t.text     "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authable_id"
    t.string   "authable_type"
  end

  add_index "thinkspace_tools_artifact_buckets", ["authable_id", "authable_type"], name: "idx_ts_tools_artifact_buckets_onauthable", using: :btree

  create_table "thinkspace_tools_artifact_files", force: true do |t|
    t.integer  "user_id"
    t.integer  "bucket_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
  end

  add_index "thinkspace_tools_artifact_files", ["ownerable_id", "ownerable_type"], name: "idx_ts_tools_artifact_files_onownerable", using: :btree

  create_table "thinkspace_tools_diagnostic_path_path_items", force: true do |t|
    t.integer  "position"
    t.integer  "path_id"
    t.integer  "parent_id"
    t.integer  "path_itemable_id"
    t.string   "path_itemable_type"
    t.integer  "user_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
  end

  add_index "thinkspace_tools_diagnostic_path_path_items", ["ownerable_id", "ownerable_type"], name: "idx_ts_tools_diagnostic_path_path_items_on_ownerable", using: :btree
  add_index "thinkspace_tools_diagnostic_path_path_items", ["path_id"], name: "idx_ts_tools_diagnostic_path_path_items_on_path_id", using: :btree

  create_table "thinkspace_tools_diagnostic_path_paths", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authable_id"
    t.string   "authable_type"
  end

  add_index "thinkspace_tools_diagnostic_path_paths", ["authable_id", "authable_type"], name: "idx_ts_tools_diagnostic_path_paths_on_authable", using: :btree

  create_table "thinkspace_tools_helper_embeds_input_element_elements", force: true do |t|
    t.string   "name"
    t.string   "element_type"
    t.integer  "helper_embedable_id"
    t.string   "helper_embedable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_tools_helper_embeds_input_element_elements", ["helper_embedable_id", "helper_embedable_type"], name: "idx_ts_tools_helper_embeds_input_element_elems_on_embedable", using: :btree

  create_table "thinkspace_tools_helper_embeds_input_element_responses", force: true do |t|
    t.integer  "element_id"
    t.integer  "user_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
  end

  add_index "thinkspace_tools_helper_embeds_input_element_responses", ["element_id"], name: "idx_ts_tools_helper_embeds_input_element_resp_on_elem_id", using: :btree
  add_index "thinkspace_tools_helper_embeds_input_element_responses", ["ownerable_id", "ownerable_type"], name: "idx_ts_tools_helper_embeds_input_element_resp_on_ownerable", using: :btree
  add_index "thinkspace_tools_helper_embeds_input_element_responses", ["user_id"], name: "idx_ts_tools_helper_embeds_input_element_resp_on_user_id", using: :btree

  create_table "thinkspace_tools_helpers_observation_list_group_lists", force: true do |t|
    t.integer  "group_id"
    t.integer  "list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_tools_helpers_observation_list_group_lists", ["group_id"], name: "idx_ts_tools_helpers_observation_list_grp_lsts_on_group_id", using: :btree
  add_index "thinkspace_tools_helpers_observation_list_group_lists", ["list_id"], name: "idx_ts_tools_helpers_observation_list_grp_lsts_on_list_id", using: :btree

  create_table "thinkspace_tools_helpers_observation_list_groups", force: true do |t|
    t.string   "title"
    t.integer  "groupable_id"
    t.string   "groupable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_tools_helpers_observation_list_groups", ["groupable_id", "groupable_type"], name: "idx_ts_tools_helpers_observation_list_groups_on_groupable", using: :btree

  create_table "thinkspace_tools_helpers_observation_list_lists", force: true do |t|
    t.string   "view_generator"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authable_id"
    t.string   "authable_type"
  end

  add_index "thinkspace_tools_helpers_observation_list_lists", ["authable_id", "authable_type"], name: "idx_ts_tools_helpers_observation_list_list_on_authable", using: :btree

  create_table "thinkspace_tools_helpers_observation_list_observation_notes", force: true do |t|
    t.integer  "observation_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_tools_helpers_observation_list_observation_notes", ["observation_id"], name: "idx_ts_tools_helpers_observation_list_notes_on_obs_id", using: :btree

  create_table "thinkspace_tools_helpers_observation_list_observations", force: true do |t|
    t.integer  "list_id"
    t.integer  "user_id"
    t.integer  "position"
    t.string   "category"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
  end

  add_index "thinkspace_tools_helpers_observation_list_observations", ["list_id"], name: "idx_ts_tools_helpers_observation_list_obs_on_list_id", using: :btree
  add_index "thinkspace_tools_helpers_observation_list_observations", ["ownerable_id", "ownerable_type"], name: "idx_ts_tools_helpers_observation_list_obs_on_ownerable", using: :btree
  add_index "thinkspace_tools_helpers_observation_list_observations", ["user_id"], name: "idx_ts_tools_helpers_observation_list_obs_on_user_id", using: :btree

  create_table "thinkspace_tools_html_contents", force: true do |t|
    t.text     "tool_content"
    t.string   "view_generator"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authable_id"
    t.string   "authable_type"
  end

  add_index "thinkspace_tools_html_contents", ["authable_id", "authable_type"], name: "idx_ts_tools_html_content_on_authable", using: :btree

  create_table "thinkspace_tools_path_viewer_viewers", force: true do |t|
    t.integer  "path_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_wips_casespace_assignments", force: true do |t|
    t.integer  "space_id"
    t.string   "title"
    t.string   "name"
    t.text     "description"
    t.text     "instructions"
    t.boolean  "active"
    t.datetime "release_at"
    t.datetime "due_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_wips_casespace_assignments", ["space_id"], name: "idx_ts_casespace_assignments_on_space_id", using: :btree

  create_table "thinkspace_wips_casespace_case_manager_templates", force: true do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "templateable_id"
    t.string   "templateable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_wips_casespace_phase_scores", force: true do |t|
    t.integer  "user_id"
    t.integer  "phase_id"
    t.decimal  "score",          precision: 9, scale: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
  end

  add_index "thinkspace_wips_casespace_phase_scores", ["ownerable_id", "ownerable_type"], name: "idx_ts_casespace_phase_scores_on_ownerable", using: :btree
  add_index "thinkspace_wips_casespace_phase_scores", ["phase_id"], name: "idx_ts_casespace_phase_scores_on_phase_id", using: :btree
  add_index "thinkspace_wips_casespace_phase_scores", ["user_id"], name: "idx_ts_casespace_phase_scores_on_user_id", using: :btree

  create_table "thinkspace_wips_casespace_phase_states", force: true do |t|
    t.integer  "user_id"
    t.integer  "phase_id"
    t.string   "current_state"
    t.datetime "archived_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ownerable_id"
    t.string   "ownerable_type"
  end

  add_index "thinkspace_wips_casespace_phase_states", ["archived_at"], name: "idx_ts_casespace_phase_states_on_archived_at", using: :btree
  add_index "thinkspace_wips_casespace_phase_states", ["ownerable_id", "ownerable_type"], name: "idx_ts_casespace_phase_states_on_ownerable", using: :btree
  add_index "thinkspace_wips_casespace_phase_states", ["phase_id"], name: "idx_ts_casespace_phase_states_on_phase_id", using: :btree
  add_index "thinkspace_wips_casespace_phase_states", ["user_id"], name: "idx_ts_casespace_phase_states_on_user_id", using: :btree

  create_table "thinkspace_wips_casespace_phase_template_sections", force: true do |t|
    t.integer  "phase_template_id"
    t.integer  "parent_id"
    t.integer  "template_section_order"
    t.string   "section_name"
    t.string   "class_names"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_wips_casespace_phase_template_sections", ["phase_template_id"], name: "idx_ts_casespace_phase_template_sections_on_phase_template_id", using: :btree

  create_table "thinkspace_wips_casespace_phase_templates", force: true do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thinkspace_wips_casespace_phase_tool_helper_embeds", force: true do |t|
    t.integer  "helper_id"
    t.integer  "phase_tool_id"
    t.string   "view_generator"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_wips_casespace_phase_tool_helper_embeds", ["helper_id"], name: "idx_ts_casespace_phase_tool_helper_embeds_on_helper_id", using: :btree
  add_index "thinkspace_wips_casespace_phase_tool_helper_embeds", ["phase_tool_id"], name: "idx_ts_casespace_phase_tool_helper_embeds_on_phase_tool_id", using: :btree

  create_table "thinkspace_wips_casespace_phase_tool_helpers", force: true do |t|
    t.integer  "helper_id"
    t.integer  "phase_tool_id"
    t.integer  "helperable_id"
    t.string   "helperable_type"
    t.integer  "phase_template_section_id"
    t.integer  "template_section_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_wips_casespace_phase_tool_helpers", ["helper_id"], name: "idx_ts_casespace_phase_tool_helpers_on_helper_id", using: :btree
  add_index "thinkspace_wips_casespace_phase_tool_helpers", ["helperable_id", "helperable_type"], name: "idx_ts_casespace_phase_tool_helpers_on_helperable", using: :btree
  add_index "thinkspace_wips_casespace_phase_tool_helpers", ["phase_template_section_id"], name: "idx_ts_casespace_phase_tool_helpers_on_pt_section_id", using: :btree
  add_index "thinkspace_wips_casespace_phase_tool_helpers", ["phase_tool_id"], name: "idx_ts_casespace_phase_tool_helpers_on_phase_tool_id", using: :btree

  create_table "thinkspace_wips_casespace_phase_tools", force: true do |t|
    t.integer  "tool_id"
    t.integer  "phase_id"
    t.integer  "toolable_id"
    t.string   "toolable_type"
    t.integer  "phase_template_section_id"
    t.integer  "template_section_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thinkspace_wips_casespace_phase_tools", ["phase_id"], name: "idx_ts_casespace_phase_tools_on_phase_id", using: :btree
  add_index "thinkspace_wips_casespace_phase_tools", ["phase_template_section_id"], name: "idx_ts_casespace_phase_tools_on_phase_template_section_id", using: :btree
  add_index "thinkspace_wips_casespace_phase_tools", ["tool_id"], name: "idx_ts_casespace_phase_tools_on_tool_id", using: :btree
  add_index "thinkspace_wips_casespace_phase_tools", ["toolable_id", "toolable_type"], name: "idx_ts_casespace_phase_tools_on_toolable", using: :btree

  create_table "thinkspace_wips_casespace_phases", force: true do |t|
    t.integer  "position"
    t.string   "title"
    t.text     "description"
    t.integer  "assignment_id"
    t.boolean  "active"
    t.integer  "phase_template_id"
    t.string   "default_state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "team_based",        default: false
  end

  add_index "thinkspace_wips_casespace_phases", ["assignment_id"], name: "idx_ts_casespace_phases_on_assignment_id", using: :btree
  add_index "thinkspace_wips_casespace_phases", ["phase_template_id"], name: "idx_ts_casespace_phases_on_phase_template_id", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
