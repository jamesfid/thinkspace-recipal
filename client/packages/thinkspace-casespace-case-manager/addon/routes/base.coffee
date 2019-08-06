import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'

export default base.extend auth_mixin,

  setupController: (controller, model) ->
    wizard_manager = @get('wizard_manager')
    wizard_manager.set_controller controller
    wizard_manager.set_route @
    if ember.isPresent(model)
      controller.set 'model', model
      controller.set 'bundle_type', (model.get('isNew') and 'selector') or model.get('bundle_type')
      controller.set 'step',  @get('wizard_manager.transition_to_step')  unless ember.isPresent(controller.get 'step')

  wizard_manager: ember.inject.service()
  case_manager:   ember.inject.service()

  get_wizard_manager: -> @get('wizard_manager')
  get_case_manager:   -> @get('case_manager')

  set_current_models: (current_models={}) -> @get_case_manager().set_current_models(current_models)

  get_current_assignment: -> @get_case_manager().get_current_assignment()

  clear_all_current_models: -> @get_case_manager().reset_all()

  get_space_from_params: (params) ->
    @store.find(ns.to_p('space'), params.space_id).then (space) =>
      @totem_messages.api_success source: @, model: space
    , (error) =>
      @totem_messages.api_failure error, source: @, model: ns.to_p('space')

  get_assignment_from_params: (params) ->
    @store.find(ns.to_p('assignment'), params.assignment_id).then (assignment) =>
      @totem_messages.api_success source: @, model: assignment
    , (error) =>
      @totem_messages.api_failure error, source: @, model: ns.to_p('assignment')

  get_phase_from_params: (params) ->
    @store.find(ns.to_p('phase'), params.phase_id).then (phase) =>
      @totem_messages.api_success source: @, model: phase
    , (error) =>
      @totem_messages.api_failure error, source: @, model: ns.to_p('phase')

  load_assignment: ->
    new ember.RSVP.Promise (resolve, reject) =>
      case_manager = @get_case_manager()
      return resolve() if case_manager.has_assignment_loaded()
      assignment = @get_current_assignment()
      options = 
        model:  assignment
        id:     assignment.get('id')
        action: 'load'
      ajax.object(options).then (payload) =>
        case_manager.set_assignment_loaded()
        @store.pushPayload(payload)
        resolve()
      , (error) => reject(error)

  load_spaces: ->
    new ember.RSVP.Promise (resolve, reject) =>
      controller = @controllerFor @ns.to_p('spaces')
      return resolve() if controller.get('all_spaces')
      @store.find(@ns.to_p 'space').then (spaces) =>
        controller.set('all_spaces', true)
        resolve()
      , (error) => reject(error)
