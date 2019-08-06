class ChangeThinkspaceCommonUsersProfileDefault < ActiveRecord::Migration
  def change
    change_column_default :thinkspace_common_users, :profile, {}
  end
end
