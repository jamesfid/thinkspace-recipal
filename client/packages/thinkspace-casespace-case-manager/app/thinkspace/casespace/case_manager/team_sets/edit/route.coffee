import ember from 'ember'
import ns from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/routes/base'

export default base.extend
  thinkspace:   ember.inject.service()
  team_manager: ember.inject.service()

  titleToken: (model) -> 'Edit ' + model.get('title')
  activate:   -> @get('thinkspace').disable_wizard_mode()
  model:      (params) ->  @store.find(ns.to_p('team_set'), params.team_set_id)

  actions:
    transition_to_team_set_show: (space, team_set) -> @transitionTo ns.to_r('case_manager', 'team_sets', 'show'), space, team_set
    transition_to_team_set_index: -> @transitionTo ns.to_r('case_manager', 'team_sets', 'index')


