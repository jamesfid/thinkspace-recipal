import ember          from 'ember'
import ns             from 'totem/ns'
import ta             from 'totem/ds/associations'
import ajax           from 'totem/ajax'
import val_mixin      from 'totem/mixins/validations'
import ckeditor_mixin from 'totem/mixins/ckeditor'
import base           from 'thinkspace-casespace-case-manager/components/wizards/steps/base'

export default base.extend val_mixin, ckeditor_mixin,
  # Properties
  step:         'logistics'
  instructions: ember.computed.reads 'model.instructions'
  release_at:   ember.computed.reads 'model.release_at'
  due_at:       ember.computed.reads 'model.due_at'
  page_title:   ember.computed.reads 'model.title'
  team_set:     null

  team_sets: ember.computed ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      assignment = @get 'model'
      assignment.get('space').then (space) =>
        space.get_team_sets(include_locked: false).then (team_sets) =>
          resolve(team_sets)
        , (error) => console.error "[logistics] Error in space.get_team_sets.", error
    ta.PromiseArray.create promise: promise

  # Components
  c_team_set: ns.to_p 'case_manager', 'assignment', 'wizards', 'assessment', 'steps', 'logistics', 'team_set'

  actions:
    complete: ->
      return unless @get('isValid')
      wizard_manager = @get('wizard_manager')
      wizard_manager.send_action 'set_instructions', @get('instructions')
      wizard_manager.send_action 'set_release_at',   @get('release_at')
      wizard_manager.send_action 'set_due_at',       @get('due_at')
      wizard_manager.send_action 'set_team_set',     @get('team_set')
      wizard_manager.send_action 'complete_step',    'logistics'

    set_team_set: (team_set) -> @set 'team_set', team_set

  validations:
    instructions:
      presence: true
    release_at:
      presence: true
    due_at:
      presence: true
