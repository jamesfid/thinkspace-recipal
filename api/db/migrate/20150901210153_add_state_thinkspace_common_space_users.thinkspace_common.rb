# This migration comes from thinkspace_common (originally 20150901000002)
class AddStateThinkspaceCommonSpaceUsers < ActiveRecord::Migration

  change_table :thinkspace_common_space_users do |t|
    t.string :state
    t.index  :state,  name: :idx_thinkspace_common_space_users_on_state
  end

  Thinkspace::Common::SpaceUser.reset_column_information
  Thinkspace::Common::SpaceUser.update_all(state: 'active')

end
