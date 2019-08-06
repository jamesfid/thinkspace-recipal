import ember from 'ember'
import ns from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/routes/base'

export default base.extend
  thinkspace:   ember.inject.service()
  team_manager: ember.inject.service()

  titleToken: (model) -> 'New Team Set for ' + model.get('title')
  activate: -> @get('thinkspace').disable_wizard_mode()
  model: (params) ->  @modelFor ns.to_p 'case_manager', 'team_sets'

  actions:
    transition_to_team_set_show: (space, team_set) -> @transitionTo ns.to_r('case_manager', 'team_sets', 'show'), space, team_set


