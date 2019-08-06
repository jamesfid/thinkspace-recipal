import ember from 'ember'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Services
  phase_manager: ember.inject.service()

  # ### Properties
  tagName: ''
  
  # ### Components
  c_phase_score: ns.to_p 'casespace', 'ownerable', 'bar', 'gradebook', 'phase', 'overview', 'score'

  # ### Events
  init: ->
    @_super()
    register_to = @get 'register_to'
    register_to.register_child @
    @callback_set_addon_ownerable()

  # ### Callbacks
  callback_set_addon_ownerable: ->
    phase        = @get('model')
    map          = @get('phase_manager.map')
    if ember.isPresent(map)
      phase_states = map.get_ownerable_phase_states(phase)
      @set 'phase_states', phase_states
    else
      @set 'phase_states', new Array
 

