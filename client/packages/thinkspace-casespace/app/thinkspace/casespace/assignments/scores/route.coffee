import ember from 'ember'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'

export default base.extend auth_mixin,
  casespace:     ember.inject.service()
  phase_manager: ember.inject.service()

  titleToken: (model) -> "Scores - #{model.get('title')}"

  renderTemplate: ->  @render()

  model: (params) ->
    @store.find(@ns.to_p('assignment'), params.assignment_id).then (assignment) =>
      @totem_messages.api_success source: @, model: assignment
    , (error) =>
      @totem_messages.api_failure error, source: @, model: @ns.to_p('assignment')

  afterModel: (assignment, transition) ->
    transition.abort()  unless assignment
    @get('casespace').set_current_models(assignment: assignment).then =>
      @get('phase_manager').set_all_phase_states()

  setupController: (controller, assignment) -> controller.set 'model', assignment