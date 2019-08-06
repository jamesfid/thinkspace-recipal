# This migration comes from thinkspace_input_element (originally 20150501000000)
class CreateThinkspaceInputElement < ActiveRecord::Migration
  def change

    create_table :thinkspace_input_element_elements, force: true do |t|
      t.references  :componentable, polymorphic: true
      t.string      :name
      t.string      :element_type
      t.timestamps
      t.index  [:componentable_id, :componentable_type],  name: :idx_thinkspace_input_elements_elements_on_componentable
    end

    create_table :thinkspace_input_element_responses, force: true do |t|
      t.references  :user
      t.references  :element
      t.references  :ownerable, polymorphic: true
      t.text        :value
      t.timestamps
      t.index  [:user_id],                        name: :idx_thinkspace_input_elements_responses_on_user
      t.index  [:element_id],                     name: :idx_thinkspace_input_elements_responses_on_element
      t.index  [:ownerable_id, :ownerable_type],  name: :idx_thinkspace_input_elements_responses_on_ownerable
    end

  end
end
