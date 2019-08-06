import ember from 'ember'
import ns from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/routes/base'

export default base.extend
  thinkspace: ember.inject.service()
  titleToken: (model) -> model.get('title')
  activate: -> @get('thinkspace').disable_wizard_mode()
  model:    (params) -> @store.find(ns.to_p('team_set'), params.team_set_id)