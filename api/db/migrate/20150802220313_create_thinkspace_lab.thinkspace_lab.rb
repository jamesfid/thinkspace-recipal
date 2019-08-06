# This migration comes from thinkspace_lab (originally 20150501000000)
class CreateThinkspaceLab < ActiveRecord::Migration
  def change

    create_table :thinkspace_lab_categories, force: true do |t|
      t.references  :chart
      t.string      :title
      t.text        :description
      t.integer     :position
      t.json        :value
      t.json        :metadata
      t.timestamps
      t.index  [:chart_id],                       name: :idx_thinkspace_labs_categories_on_chart
    end

    create_table :thinkspace_lab_charts, force: true do |t|
      t.references  :authable, polymorphic: true
      t.string      :title
      t.text        :description
      t.timestamps
      t.index  [:authable_id, :authable_type],    name: :idx_thinkspace_charts_on_authable
    end

    create_table :thinkspace_lab_observations, force: true do |t|
      t.references  :result
      t.references  :ownerable, polymorphic: true
      t.integer     :attempts, default: 0
      t.boolean     :all_correct, default: false
      t.string      :state
      t.json        :value
      t.json        :detail
      t.json        :archive
      t.timestamps
      t.index  [:result_id],                      name: :idx_thinkspace_labs_observations_on_result
      t.index  [:ownerable_id, :ownerable_type],  name: :idx_thinkspace_labs_observations_on_ownerable
    end

    create_table :thinkspace_lab_results, force: true do |t|
      t.references  :category
      t.string      :title
      t.integer     :position
      t.integer     :max_attempts, default: 0
      t.json        :value
      t.json        :metadata
      t.timestamps
      t.index  [:category_id],                    name: :idx_thinkspace_labs_results_on_category
    end

  end
end
