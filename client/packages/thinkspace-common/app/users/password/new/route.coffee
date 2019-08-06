import ember from 'ember'
import ns from 'totem/ns'

export default ember.Route.extend
  #titleToken: -> 'Password Reset'

  setupController: (controller, model) ->
    model = @store.createRecord ns.to_p('password_reset')
    controller.set('model', model)