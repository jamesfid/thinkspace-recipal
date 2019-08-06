import ember from 'ember'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  model_state: null

  is_approved:  ember.computed.equal 'model_state', 'approved'
  is_neutral:   ember.computed.equal 'model_state', 'neutral'
  is_sent:      ember.computed.equal 'model_state', 'sent'
  is_submitted: ember.computed.equal 'model_state', 'submitted'
  is_ignored:   ember.computed.equal 'model_state', 'ignored'

  state_text: ember.computed 'model_state', ->
    model_state = @get('model_state')

    if ember.isPresent(model_state)
      if model_state == 'neutral'
        state_text = 'In-Progress'
      else
        state_text = model_state.charAt(0).toUpperCase() + model_state.slice(1)

      return state_text
