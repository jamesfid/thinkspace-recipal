import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Properties
  all_spaces:             null
  current_route:          null
  toolbar_is_hidden:      ember.computed.reads 'thinkspace.toolbar_is_hidden'
  toolbar_is_minimized:   ember.computed.reads 'thinkspace.toolbar_is_minimized'
  sidepocket_is_expanded: ember.computed.reads 'thinkspace.sidepocket_is_expanded'
  terms_modal_visible:    ember.computed.reads 'thinkspace.display_terms_modal'
  has_sticky_addon:       ember.computed.reads 'casespace.has_sticky_addon'

  # ### Components
  c_toolbar:     ns.to_p 'toolbar'
  c_dock:        ns.to_p 'dock'
  c_spaces:      ns.to_p 'spaces'
  c_messages:    ns.to_p 'dock', 'messages', 'messages'
  c_terms_modal: ns.to_p 'common', 'user', 'terms_modal'

  # ### Services
  thinkspace: ember.inject.service()
  casespace:  ember.inject.service()
