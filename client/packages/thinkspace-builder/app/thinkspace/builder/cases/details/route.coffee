import ember      from 'ember'
import ns         from 'totem/ns'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'

export default base.extend auth_mixin,
  # ### Services
  builder: ember.inject.service()

  # ### Properties
  titleToken: 'Details'

  model: (params) ->
    @tc.find_record ns.to_p('assignment'), params.case_id

  # ### Events
  setupController: (controller, model) ->
    builder = @get 'builder'
    builder.set_current_step_from_id 'details'
    builder.set_model model
    controller.set 'model', model