import ember      from 'ember'
import ns         from 'totem/ns'
import base       from 'thinkspace-casespace-case-manager/components/wizards/steps/base'
import val_mixin  from 'totem/mixins/validations'

export default base.extend val_mixin,
  # Properties
  label:          ember.computed.reads 'model.label'
  feedback_type:  ember.computed.reads 'model.feedback_type'
  feedback_types: ['positive', 'constructive']

  # Upstream actions
  remove_qualitative_item: 'remove_qualitative_item'


  actions:
    set_feedback_type:       (value) -> ember.set @get('model'), 'feedback_type', value
    set_label:               (value) -> ember.set @get('model'), 'label', value
    remove_qualitative_item: -> @sendAction 'remove_qualitative_item', @get('model')
