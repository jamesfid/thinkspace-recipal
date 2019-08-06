# This migration comes from thinkspace_diagnostic_path_viewer (originally 20150501000000)
class CreateThinkspaceDiagnosticPathViewer < ActiveRecord::Migration
  def change

    create_table :thinkspace_diagnostic_path_viewer_viewers, force: true do |t|
      t.references  :user
      t.references  :path
      t.references  :authable, polymorphic: true
      t.references  :ownerable, polymorphic: true
      t.timestamps
      t.index  [:path_id],                        name: :idx_thinkspace_diagnostic_path_viewer_viewers_on_path
      t.index  [:authable_id, :authable_type],    name: :idx_thinkspace_diagnostic_path_viewer_viewers_on_authable
      t.index  [:ownerable_id, :ownerable_type],  name: :idx_thinkspace_diagnostic_path_viewer_viewers_on_ownerable
    end

  end
end
