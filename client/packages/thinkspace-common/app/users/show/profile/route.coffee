import ember      from 'ember'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'
import ns         from 'totem/ns'

export default base.extend
  model: -> @modelFor('users.show')

  setupController: (controller, model) ->
    controller.set('model', model)

  renderTemplate: ->
    @render(ns.to_p('users', 'show', 'profile'))