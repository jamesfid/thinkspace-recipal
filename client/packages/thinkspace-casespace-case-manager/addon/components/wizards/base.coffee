import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  step:         '' # Step name for the current step.
  steps:        [] # Array of all of the steps, in order.
  default_step: ember.computed -> @get('steps.firstObject')
  is_editing:   ember.computed.not 'model.isNew'
  debug:        true

  # Services
  thinkspace:     ember.inject.service()
  case_manager:   ember.inject.service()
  wizard_manager: ember.inject.service()

  # Components
  c_validated_input: ns.to_p 'common', 'shared', 'validated_input'

  init: ->
    wizard_manager = @get('wizard_manager')
    console.log "[wizard] init called, setting service...", wizard_manager if @get('debug')
    wizard_manager.set('wizard', @)
    @_super()

  check_bundle_type: (bundle_type, options={}) -> new ember.RSVP.Promise (resolve, reject) => resolve()
  check_step: (step, options={}) -> new ember.RSVP.Promise (resolve, reject) => resolve()

  actions:
    complete_step: (step) ->
      fn         = "complete_#{step}"
      console.log "[wizard] Completing step with fn: ", step, fn if @get('debug')
      steps      = @get('steps')
      step_index = steps.indexOf(step)
      next_step  = steps[step_index + 1] if ember.isPresent(step_index)

      return ember.RSVP.resolve() unless typeof @[fn] == 'function'

      @[fn]().then (should_return=false) =>
        return if should_return
        console.log "[wizard] Step, next_step: ", step, next_step if @get('debug')
        @get('wizard_manager').set_query_param 'step', next_step, direction: 'forward' if ember.isPresent(next_step)
        @get('thinkspace').scroll_to_top()

    back: (step) ->
      steps      = @get('steps')
      step_index = steps.indexOf(step)
      prev_step  = steps[step_index - 1] if ember.isPresent(step_index)
      if ember.isPresent(prev_step)
        @get('wizard_manager').set_query_param 'step', prev_step, direction: 'back' 
      else
        @get('wizard_manager').transition_to_selector()

    go_to_step: (step) ->
      steps      = @get('steps')
      step_index = steps.indexOf(step)
      go_step    = steps[step_index] if ember.isPresent(step_index)
      if ember.isPresent(go_step)
        @get('wizard_manager').set_query_param 'step', go_step, direction: 'back' 
      else
        @get('wizard_manager').transition_to_selector()
