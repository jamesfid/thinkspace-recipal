import ember from 'ember'
import base  from 'thinkspace-casespace-case-manager/routes/base'
import ns from 'totem/ns'

export default base.extend
  thinkspace:   ember.inject.service()
  team_manager: ember.inject.service()

  activate: ->  @get('thinkspace').disable_wizard_mode()
  model: (params) -> @get('team_manager').get_team_set_from_params(params)
  setupController: (controller, model) ->
    @get('team_manager').set_team_set_and_space(model).then => controller.set('model', model)
