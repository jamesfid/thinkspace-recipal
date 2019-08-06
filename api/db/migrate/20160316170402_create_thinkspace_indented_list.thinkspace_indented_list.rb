# This migration comes from thinkspace_indented_list (originally 20160115000000)
class CreateThinkspaceIndentedList < ActiveRecord::Migration
  def change

    create_table :thinkspace_indented_list_lists, force: true do |t|
      t.references  :authable, polymorphic: true
      t.string      :title
      t.boolean     :expert
      t.json        :settings
      t.timestamps
      t.index  [:authable_id, :authable_type], name: :idx_thinkspace_indented_list_lists_on_authable
      t.index  [:expert],                      name: :idx_thinkspace_indented_list_lists_on_expert
    end

    create_table :thinkspace_indented_list_expert_responses, force: true do |t|
      t.references  :user
      t.references  :list
      t.references  :response
      t.string      :state
      t.json        :value
      t.timestamps
      t.index  [:state],       name: :idx_thinkspace_indented_list_expert_responses_on_state
      t.index  [:list_id],     name: :idx_thinkspace_indented_list_expert_responses_on_list
      t.index  [:response_id], name: :idx_thinkspace_indented_list_expert_responses_on_response
    end

    create_table :thinkspace_indented_list_responses, force: true do |t|
      t.references  :user
      t.references  :list
      t.references  :ownerable, polymorphic: true
      t.json        :value
      t.timestamps
      t.index  [:list_id],                         name: :idx_thinkspace_indented_list_responses_on_list
      t.index  [:ownerable_id, :ownerable_type],   name: :idx_thinkspace_indented_list_responses_on_ownerable
    end

  end
end
