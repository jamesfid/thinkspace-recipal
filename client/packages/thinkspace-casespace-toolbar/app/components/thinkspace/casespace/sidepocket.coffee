import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Properties
  tagName:       ''
  current_route: null
  model:         ember.computed.reads 'casespace.current_phase'

  # ### Services
  thinkspace: ember.inject.service()
  casespace:  ember.inject.service()

  # ### Components
  c_sidepocket_component: ember.computed.reads 'casespace.c_sidepocket_component'
  has_sticky_addon:       ember.computed.reads 'casespace.has_sticky_addon'


  # ### Observers
  sidepocket_reset: ember.observer 'current_route', ->
    casespace = @get('casespace')
    casespace.hide_sidepocket() if casespace.get('sidepocket_is_expanded')
