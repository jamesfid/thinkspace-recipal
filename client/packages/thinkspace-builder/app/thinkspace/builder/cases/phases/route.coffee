import ember      from 'ember'
import ns         from 'totem/ns'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'

export default base.extend auth_mixin,
  # ### Services
  builder: ember.inject.service()

  # ### Properties
  titleToken: 'Phases'

  model: (params) ->
    @tc.query ns.to_p('assignment'), {id: params.case_id, action: 'load'}, single: true

  # ### Events
  setupController: (controller, model) ->
    builder = @get 'builder'
    builder.set_current_step_from_id 'phases'
    builder.set_model model
    controller.set 'model', model
