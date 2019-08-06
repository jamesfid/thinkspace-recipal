import ember from 'ember'
import base  from 'thinkspace-readiness-assurance/base/admin/menu'

export default base.extend

  menu: ember.computed.reads 'am.irat_to_trat_menu'

  # ### TESTING ONLY - auto-select
  didInsertElement: ->
    # @select_action @find_config(@am.c_irat_to_trat_due_at)
    # @select_action @find_config(@am.c_irat_to_trat_after)
  # ### TESTING ONLY
