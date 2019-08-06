# This migration comes from thinkspace_artifact (originally 20150501000000)
class CreateThinkspaceArtifact < ActiveRecord::Migration
  def change

    create_table :thinkspace_artifact_buckets, force: true do |t|
      t.references  :user
      t.references  :authable, polymorphic: true
      t.text        :instructions
      t.timestamps
      t.index  [:user_id],                      name: :idx_thinkspace_artifact_buckets_on_user
      t.index  [:authable_id, :authable_type],  name: :idx_thinkspace_artifact_buckets_on_authable
    end

    create_table :thinkspace_artifact_files, force: true do |t|
      t.references  :user
      t.references  :bucket
      t.references  :ownerable, polymorphic: true
      t.string      :attachment_file_name
      t.string      :attachment_content_type
      t.integer     :attachment_file_size
      t.datetime    :attachment_updated_at
      t.timestamps
      t.index  [:user_id],                         name: :idx_thinkspace_artifact_files_on_user
      t.index  [:bucket_id],                       name: :idx_thinkspace_artifact_files_on_bucket
      t.index  [:ownerable_id, :ownerable_type],   name: :idx_thinkspace_artifact_files_on_ownerable
    end

  end
end
