import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-readiness-assurance/base/admin/menu'

export default base.extend

  ra:   ember.inject.service ns.to_p('ra')
  menu: ember.computed.reads 'am.dashboard_menu'

  r_model: ember.computed ->
    model = @get('model')
    route = @totem_scope.get_record_path(model).pluralize()
    "#{route}.show"

  willInsertElement: ->
    @am.set_model @get('model')
    ra   = @get('ra')
    room = ra.get_admin_room()
    ra.messages.load({room})

  willDestroy: -> @am.reset()

  # ### TESTING ONLY - auto-select
  didInsertElement: ->
    # @select_action @find_config(@am.c_menu_messages)
    # @select_action @find_config(@am.c_menu_irat)
    # @select_action @find_config(@am.c_menu_timers)
    # @select_action @find_config(@am.c_timers_active)
  # ### TESTING ONLY
