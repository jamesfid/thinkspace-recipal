# This migration comes from thinkspace_reporter (originally 20160822000000)
class CreateThinkspaceReporterFiles < ActiveRecord::Migration
  def change

    create_table :thinkspace_reporter_files, force: true do |t|
      t.references  :user
      t.references  :report
      t.string      :attachment_file_name
      t.string      :attachment_content_type
      t.integer     :attachment_file_size
      t.datetime    :attachment_updated_at
      t.timestamps
      t.index  [:user_id],  name: :idx_thinkspace_reporter_files_on_user
    end

  end
end

