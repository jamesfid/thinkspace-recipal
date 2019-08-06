# This migration comes from thinkspace_reporter (originally 20160822000001)
class CreateThinkspaceReporterReports < ActiveRecord::Migration
  def change

    create_table :thinkspace_reporter_reports, force: true do |t|
      t.string      :title
      t.references  :user
      t.references  :authable, polymorphic: true
      t.json        :value
      t.timestamps
      t.index  [:user_id],  name: :idx_thinkspace_reporter_reports_on_user
      t.index  [:authable_type, :authable_id],  name: :idx_thinkspace_reporter_reports_on_authable
    end

  end
end

