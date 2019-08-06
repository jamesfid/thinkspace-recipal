import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/routes/base'

export default base.extend
  titleToken: 'Case Manager'

  thinkspace: ember.inject.service()

  activate: -> @get('thinkspace').enable_wizard_mode()

  deactivate: ->
    @get_case_manager().reset_all()
    @get_wizard_manager().reset_all()
    @get('thinkspace').disable_wizard_mode()

  actions:
    exit: ->
      controller = @get('wizard_manager.controller')
      controller.set 'step', null  if controller  # ensure starts with first wizard step
      thinkspace = @get('thinkspace')
      transition = thinkspace.get_current_transition()
      if ember.isBlank(transition) or thinkspace.transition_is_for(transition, 'case_manager')
        @transitionTo(ns.to_r 'spaces')
      else
        transition.retry()
