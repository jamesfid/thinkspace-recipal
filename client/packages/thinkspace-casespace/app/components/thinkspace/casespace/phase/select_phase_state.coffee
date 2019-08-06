import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  phase_manager: ember.inject.service()

  phase_states: ember.computed 'model', -> @get('phase_manager.map').get_ownerable_phase_states(@get 'model')

  actions:
    select_phase_state: (phase_state) -> @sendAction 'select_phase_state', phase_state
