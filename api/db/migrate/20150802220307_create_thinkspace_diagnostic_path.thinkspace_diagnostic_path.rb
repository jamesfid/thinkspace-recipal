# This migration comes from thinkspace_diagnostic_path (originally 20150501000000)
class CreateThinkspaceDiagnosticPath < ActiveRecord::Migration
  def change

    create_table :thinkspace_diagnostic_path_paths, force: true do |t|
      t.references  :authable, polymorphic: true
      t.string      :title
      t.timestamps
      t.index  [:authable_id, :authable_type], name: :idx_thinkspace_diagnostic_path_paths_on_authable
    end

    create_table :thinkspace_diagnostic_path_path_items, force: true do |t|
      t.references  :user
      t.references  :path
      t.references  :ownerable, polymorphic: true
      t.references  :parent
      t.references  :path_itemable, polymorphic: true
      t.integer     :position
      t.text        :description
      t.timestamps
      t.index  [:path_id],                          name: :idx_thinkspace_diagnostic_path_path_items_on_path
      t.index  [:ownerable_id, :ownerable_type],    name: :idx_thinkspace_diagnostic_path_path_items_on_ownerable
    end

  end
end
