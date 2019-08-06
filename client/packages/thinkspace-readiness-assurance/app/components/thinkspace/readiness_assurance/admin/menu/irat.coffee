import ember from 'ember'
import base  from 'thinkspace-readiness-assurance/base/admin/menu'

export default base.extend

  menu: ember.computed.reads 'am.irat_menu'

  # ### TESTING ONLY - auto-select
  didInsertElement: ->
    # @select_action @find_config(@am.c_messages_view)
    # @select_action @find_config(@am.c_menu_irat_to_trat)
    # @select_action @find_config(@am.c_irat_phase_states)
  # ### TESTING ONLY
