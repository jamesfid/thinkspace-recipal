import ember      from 'ember'
import ns         from 'totem/ns'
import base       from 'thinkspace-casespace-case-manager/components/wizards/steps/base'
import val_mixin  from 'totem/mixins/validations'

export default base.extend val_mixin,
  # Properties
  step:       'details'
  title:      null
  page_title: 'New Case'

  actions:
    complete: ->
      return unless @get('isValid')
      wizard_manager = @get('wizard_manager')
      wizard_manager.send_action 'set_title', @get('title')
      wizard_manager.send_action 'complete_step', 'details'

  validations:
    title:
      presence: true
