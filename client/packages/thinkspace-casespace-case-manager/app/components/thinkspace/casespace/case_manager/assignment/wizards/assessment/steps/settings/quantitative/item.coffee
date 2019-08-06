import ember      from 'ember'
import ns         from 'totem/ns'
import base       from 'thinkspace-casespace-case-manager/components/wizards/steps/base'
import val_mixin  from 'totem/mixins/validations'

export default base.extend val_mixin,
  # Properties
  label: ember.computed.reads 'model.label'
  
  actions:
    set_label: (value) -> ember.set @get('model'), 'label', value
