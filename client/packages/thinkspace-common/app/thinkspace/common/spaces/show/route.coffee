import ember from 'ember'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'

export default base.extend auth_mixin,
  thinkspace: ember.inject.service()
  casespace:  ember.inject.service()

  titleToken: (model) -> model.get('title')

  beforeModel: (transition) ->
    @get('thinkspace').set_current_transition(transition)
    @_super(transition)

  model: (params) ->
    @store.find(@ns.to_p('space'), params.space_id).then (space) =>
      @totem_messages.api_success source: @, model: space
    , (error) =>
      @totem_messages.api_failure error, source: @, model: @ns.to_p('space')

  setupController: (controller, model) -> controller.set 'model', model

  renderTemplate: (controller, model) -> @get('casespace').set_current_models(space: model).then => @render()
