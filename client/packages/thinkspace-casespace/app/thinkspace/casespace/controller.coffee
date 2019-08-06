import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Controller.extend
  needs: ['application'] # Still used for currentRouteName access.

  # ### Properties
  current_route: ember.computed.reads 'controllers.application.currentRouteName' 

  # ### Components
  c_casespace: ns.to_p 'casespace'
