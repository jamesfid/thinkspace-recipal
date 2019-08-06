import ember from 'ember'
import base  from 'thinkspace-casespace-case-manager/routes/base'
import ns from 'totem/ns'

export default base.extend
  thinkspace:   ember.inject.service()
  team_manager: ember.inject.service()

  titleToken: 'Team Sets'

  activate:       ->  @get('thinkspace').disable_wizard_mode()
  model: (params) ->  @get('team_manager').get_space_from_params(params)

  setupController: (controller, model) ->
    new ember.RSVP.Promise (resolve, reject) =>
      team_manager = @get('team_manager')
      team_manager.set_space_roster(model).then =>
        resolve()
