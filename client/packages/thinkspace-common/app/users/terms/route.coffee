import ember      from 'ember'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import ns         from 'totem/ns'

export default ember.Route.extend auth_mixin,
  model: -> @modelFor('users.show')

  setupController: (controller, model) ->
    controller.set('model', model)
    query =
      action: 'latest_for'
      verb:   'GET'
      data:   
        doc_type: 'terms_of_service'

    @tc.query(ns.to_p('agreement'), query, single: true).then (tos) =>
      controller.set('tos', tos)

  renderTemplate: -> @render(ns.to_p('users', 'terms'))