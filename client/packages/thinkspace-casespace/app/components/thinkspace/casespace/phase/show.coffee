import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  totem_data_config: metadata: {module_only: true}  # include module to unload assignment in submit action

  tvo:           ember.inject.service()
  phase_manager: ember.inject.service()

  has_responses:          ember.computed.bool  'tvo.status.elements'
  valid_elements_count:   ember.computed.reads 'tvo.status.elements.count.valid'
  invalid_elements_count: ember.computed.reads 'tvo.status.elements.count.invalid'

  actions:
    submit: ->
      assignment = @get('phase_manager').get_assignment()
      @totem_data.metadata.unload(assignment)
      @sendAction('submit')
