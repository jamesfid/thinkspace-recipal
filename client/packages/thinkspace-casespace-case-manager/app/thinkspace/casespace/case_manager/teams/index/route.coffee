import ember from 'ember'
import base  from 'thinkspace-casespace-case-manager/routes/base'
import ns from 'totem/ns'

export default base.extend
  thinkspace: ember.inject.service()

  activate: ->  @get('thinkspace').disable_wizard_mode()
  model: (params) ->  @modelFor ns.to_p 'case_manager', 'team_sets'
