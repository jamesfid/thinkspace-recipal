import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  casespace:     ember.inject.service()
  phase_manager: ember.inject.service()

  current_space:      ember.computed.reads 'casespace.current_space'
  current_assignment: ember.computed.reads 'casespace.current_assignment'
  current_phase:      ember.computed.reads 'casespace.current_phase'
  addon_ownerable:    ember.computed.reads 'casespace.active_addon_ownerable'

  has_phase_view: ember.computed.and 'current_phase', 'phase_manager.has_phase_view'

  addon_name:         null
  addon_display_name: null
  toggle_width_text:  null

  addon_visible:   false
  addon_maximized: false

  t_toggle_width: ns.to_t 'dock', 'shared', 'toggle_width'

  is_current_html: '<i class="fa fa-check-circle">'

  addon_visible_on:  -> @set 'addon_visible', true
  addon_visible_off: -> @set 'addon_visible', false

  actions:
    toggle_addon_visible: ->
      if @toggleProperty('addon_visible')
        @send 'toggle_width'  unless @get('addon_maximized')
        @set_active_addon()
      else
        @send 'exit'

    toggle_width: -> @set 'toggle_width_text', (@toggleProperty('addon_maximized') and 'Hide') or "Show #{@get('addon_display_name')}"
  
    exit: ->
      @exit_addon_common()
      @set_ownerable()
      @generate_phase_view()  if @get('current_phase')

  exit_addon: -> return  # individual docks should override this when needed

  exit_addon_common: ->
    @mock_phase_states_off()
    @addon_visible_off()
    @reset_active_addon()

  set_active_addon: (component=@)         -> @get('casespace').set_active_addon(component)
  set_active_addon_ownerable: (ownerable) -> @get('casespace').set_active_addon_ownerable(ownerable)
  reset_active_addon:                     -> @get('casespace').reset_active_addon()

  mock_phase_states_on:           -> @get('phase_manager').mock_phase_states_on()
  mock_phase_states_off:          -> @get('phase_manager').mock_phase_states_off()
  set_ownerable: (ownerable=null) -> @get('phase_manager').set_ownerable(ownerable)
  generate_phase_view:            -> @get('phase_manager').generate_view_with_ownerable()
