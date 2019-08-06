import ember from 'ember'
import ns    from 'totem/ns'
import lab_observation from 'thinkspace-lab/vet_med_lab_observation'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  init: ->
    @_super()
    @set 'lab_observation', lab_observation.create
      lab:             @get 'lab'
      lab_result:      @get 'lab_result'
      result:          @get 'result'
      component:       @
      observation_key: @get 'observation_key'

  observation_key: ember.computed -> @get('column.observation')

  c_select:      ns.to_p 'lab:observation', 'vet_med', 'select'
  c_input:       ns.to_p 'lab:observation', 'vet_med', 'input'
  c_correctable: ns.to_p 'lab:observation', 'vet_med', 'correctable'

  input_type:     ember.computed -> @get('lab_observation').get_result_value('input_type')
  is_select:      ember.computed.equal 'input_type', 'select'
  is_input:       ember.computed.equal 'input_type', 'input'
  is_correctable: ember.computed.equal 'input_type', 'correctable'
