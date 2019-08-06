class ChangeThinkspaceCommonUsersProfile < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up { change_column :thinkspace_common_users, :profile, 'jsonb USING CAST(profile AS jsonb)' }
      dir.down { change_column :thinkspace_common_users, :profile, 'json USING CAST(profile AS json)' }
    end
  end
end
