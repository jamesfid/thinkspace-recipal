class AddThinkspaceCommonKeys < ActiveRecord::Migration
  def change
    create_table :thinkspace_common_keys, force: true do |t|
      t.string   :key
      t.string   :source
      t.string   :category
      t.datetime :expires_at
      t.timestamps
      t.index [:key], name: :idx_thinkspace_common_keys
    end

    create_table :thinkspace_common_user_keys, force: true do |t|
      t.references :user
      t.references :key
      t.timestamps
      t.index [:user_id, :key_id], name: :idx_thinkspace_common_user_keys_on_user
    end
  end
end
