import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  toolbar_is_hidden:      ember.computed.reads 'thinkspace.toolbar_is_hidden'
  toolbar_is_minimized:   ember.computed.reads 'thinkspace.toolbar_is_minimized'
  sidepocket_is_expanded: ember.computed.reads 'casespace.sidepocket_is_expanded'
  sidepocket_width_class: ember.computed.reads 'casespace.sidepocket_width_class'
  dock_is_visible:        ember.computed.reads 'casespace.dock_is_visible'
  terms_modal_visible:    ember.computed.reads 'thinkspace.display_terms_modal'
  has_sticky_addon:       ember.computed.reads 'casespace.has_sticky_addon'

  # Components
  c_toolbar:     ns.to_p('toolbar')
  c_dock:        ns.to_p('dock')
  c_sidepocket:  ns.to_p('sidepocket')
  c_messages:    ns.to_p('dock', 'messages', 'messages')
  c_terms_modal: ns.to_p('common', 'user', 'terms_modal')
  
  # Services
  thinkspace: ember.inject.service()
  casespace:  ember.inject.service()
