import ember          from 'ember'
import ns             from 'totem/ns'
import base           from 'thinkspace-casespace-case-manager/components/wizards/steps/base'
import val_mixin      from 'totem/mixins/validations'
import ckeditor_mixin from 'totem/mixins/ckeditor'

export default base.extend val_mixin, ckeditor_mixin,
  # Properties
  step:         'logistics'
  instructions: ember.computed.reads 'model.instructions'
  release_at:   ember.computed.reads 'model.release_at'
  due_at:       ember.computed.reads 'model.due_at'
  page_title:   ember.computed.reads 'model.title'
  model_state:  ember.computed.reads 'model.state' # https://github.com/emberjs/ember.js/issues/4764

  actions:
    complete: ->
      return unless @get('isValid')
      wizard_manager = @get('wizard_manager')
      wizard_manager.send_action 'set_instructions', @get('instructions')
      wizard_manager.send_action 'set_release_at',   @get('release_at')
      wizard_manager.send_action 'set_due_at',       @get('due_at')
      wizard_manager.send_action 'set_model_state',  @get('model_state')
      wizard_manager.send_action 'complete_step',    'logistics'


  validations:
    release_at:
      presence: true
    due_at:
      presence: true
