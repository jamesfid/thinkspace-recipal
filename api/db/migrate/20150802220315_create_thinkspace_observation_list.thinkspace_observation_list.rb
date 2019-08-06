# This migration comes from thinkspace_observation_list (originally 20150501000000)
class CreateThinkspaceObservationList < ActiveRecord::Migration
  def change

    create_table :thinkspace_observation_list_group_lists, force: true do |t|
      t.references  :group
      t.references  :list
      t.timestamps
      t.index  [:group_id],                       name: :idx_thinkspace_observation_list_group_lists_on_group
      t.index  [:list_id],                        name: :idx_thinkspace_observation_list_group_lists_on_list
    end

    create_table :thinkspace_observation_list_groups, force: true do |t|
      t.references  :groupable, polymorphic: true
      t.string      :title
      t.timestamps
      t.index  [:groupable_id, :groupable_type],    name: :idx_thinkspace_observation_list_groups_on_groupable
    end

    create_table :thinkspace_observation_list_lists, force: true do |t|
      t.references :authable, polymorphic: true
      t.json       :category
      t.timestamps
      t.index  [:authable_id, :authable_type],       name: :idx_thinkspace_observation_list_lists_on_authable
    end

    create_table :thinkspace_observation_list_observation_notes, force: true do |t|
      t.references  :observation
      t.text        :value
      t.timestamps
      t.index  [:observation_id],                 name: :idx_thinkspace_observation_list_observation_notes_on_obs
    end

    create_table :thinkspace_observation_list_observations, force: true do |t|
      t.references  :user
      t.references  :list
      t.references  :ownerable, polymorphic: true
      t.integer     :position
      t.text        :value
      t.timestamps
      t.index  [:list_id],                        name: :idx_thinkspace_observation_list_observations_on_list
      t.index  [:user_id],                        name: :idx_thinkspace_observation_list_observations_on_user
      t.index  [:ownerable_id, :ownerable_type],  name: :idx_thinkspace_observation_list_observations_on_ownerable
    end

  end
end
