import ember from 'ember'
import base  from 'thinkspace-readiness-assurance/base/admin/menu'

export default base.extend

  menu: ember.computed.reads 'am.timers_menu'

  # ### TESTING ONLY - auto-select
  # didInsertElement: ->
  #   @select_action @find_config(@am.c_timer_index)
  # ### TESTING ONLY
