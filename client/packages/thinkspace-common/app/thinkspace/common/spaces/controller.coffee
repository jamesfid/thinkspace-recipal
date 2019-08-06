import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Controller.extend
  needs: ['application'] # Still used for currentRouteName access. 

  # ### Properties
  all_spaces:    null
  current_route: ember.computed.reads 'controllers.application.currentRouteName'
  
  # ### Services
  thinkspace: ember.inject.service()

  # ### Components
  c_spaces:  ns.to_p 'spaces'