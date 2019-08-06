import ember from 'ember'
import ns from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/routes/base'

export default base.extend
  thinkspace: ember.inject.service()
  
  activate: -> @get('thinkspace').disable_wizard_mode()

  model: (params) -> @store.find(ns.to_p('assignment'), params.assignment_id)