import ember          from 'ember'
import ns             from 'totem/ns'
import lab_result     from 'thinkspace-lab/vet_med_lab_result'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  init: ->
    @_super()
    @set 'lab_result', lab_result.create
      lab:    @get 'lab'
      result: @get 'model'
      
  # ### Components
  c_observation: ember.computed -> ns.to_p 'lab:observation', @get('category.value.component')

  # observation_key: ember.computed -> @get('column.observation')

  # c_select:      ns.to_p 'lab:observation', 'vet_med', 'select'
  # c_input:       ns.to_p 'lab:observation', 'vet_med', 'input'
  # c_correctable: ns.to_p 'lab:observation', 'vet_med', 'correctable'

  # input_type:     ember.computed -> @get('lab_observation').get_result_value('input_type')
  # is_select:      ember.computed.equal 'input_type', 'select'
  # is_input:       ember.computed.equal 'input_type', 'input'
  # is_correctable: ember.computed.equal 'input_type', 'correctable'
