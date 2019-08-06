import ember      from 'ember'
import ns         from 'totem/ns'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'

export default base.extend auth_mixin,
  # ### Services
  builder: ember.inject.service()

  # ### Properties
  titleToken: 'Edit'

  model: (params) -> @tc.find_record ns.to_p('phase'), params.phase_id

  # ### Events  
  setupController: (controller, model) ->
    @totem_scope.set_authable model
    builder = @get 'builder'
    builder.set_model model
    builder.set_current_step_from_id 'phases' # To ensure the phases button is selected
    controller.set 'model', model
