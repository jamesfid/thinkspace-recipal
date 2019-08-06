import ember      from 'ember'
import ns         from 'totem/ns'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'

export default base.extend auth_mixin,
  casespace:    ember.inject.service()

  titleToken: (model) -> 'Report Download'

  model: (params) -> params

  setupController: (controller, params) -> 
    controller.set 'token', params.token