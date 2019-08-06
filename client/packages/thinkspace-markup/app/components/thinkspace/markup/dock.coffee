import ember   from 'ember'
import ns      from 'totem/ns'
import base    from 'thinkspace-casespace/components/dock_base'

export default base.extend
  casespace:  ember.inject.service()

  addon_display_name: 'Comments'

  can_access_addon: true
  is_addon_visible: false

  open_addon: ->
    @get('casespace').set_active_sidepocket_component ns.to_p('markup', 'sidepocket', 'discussions')

  close_addon: ->
    @get('casespace').reset_active_sidepocket_component()

  actions:
    toggle_addon_visible: ->
      is_addon_visible = @toggleProperty('is_addon_visible')
      casespace        = @get('casespace')
      if is_addon_visible then @open_addon() else @close_addon()