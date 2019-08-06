# This migration comes from thinkspace_common (originally 20150901000001)
class AddStateThinkspaceCommonSpaces < ActiveRecord::Migration

  change_table :thinkspace_common_spaces do |t|
    t.string :state
    t.index  :state,  name: :idx_thinkspace_common_spaces_on_state
  end

  Thinkspace::Common::Space.reset_column_information
  Thinkspace::Common::Space.update_all(state: 'active')

end
