import ember from 'ember'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'

export default base.extend auth_mixin,
  thinkspace: ember.inject.service()

  titleToken: 'Spaces'

  activate: -> @get('thinkspace').disable_wizard_mode()

  model: ->
    controller = @controllerFor @ns.to_p('spaces')
    return if controller.get('all_spaces')
    @store.find(@ns.to_p 'space').then (spaces) =>
      controller.set('all_spaces', true)
      @totem_messages.api_success model: spaces
    , (error) =>
      @totem_messages.api_failure error, source: @, model: @ns.to_p('space')

  renderTemplate: -> @render()
