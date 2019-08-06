import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  phase_manager: ember.inject.service()

  r_phases_show: ns.to_r 'phases', 'show'

  has_multiple_phase_states: ember.computed 'phase_states', -> @get('phase_states.length') > 1
  is_current_phase:          ember.computed -> @get('model') == @get('current_phase')
  is_select_phase_state:     ember.computed.and 'is_current_phase', 'has_multiple_phase_states'

  phase_states: ember.computed ->
    phase = @get('model')
    if @get('phase_manager').has_active_addon()
      @get('phase_manager.map').get_ownerable_phase_states(phase)
    else
      @get('phase_manager.map').get_current_user_phase_states(phase)

  actions:
    select: (phase_state) -> @sendAction 'select', phase_state