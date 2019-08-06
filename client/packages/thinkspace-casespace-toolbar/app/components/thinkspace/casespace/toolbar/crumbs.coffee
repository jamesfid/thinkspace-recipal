import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  casespace: ember.inject.service()

  totem_data_config: ability: {ajax_source: ns.to_p('spaces')}

  current_space:      ember.computed.reads 'casespace.current_space'
  current_assignment: ember.computed.reads 'casespace.current_assignment'
  current_phase:      ember.computed.reads 'casespace.current_phase'

  is_user_profile: false
  display_space: ember.computed 'current_space', 'is_user_profile', -> ember.isPresent(@get('current_space')) or @get('is_user_profile')

  # Set in the session data whether the signed in user can switch users.
  # This does NOT persist accross page reloads, but the switch-authenticator will set this to true.
  observe_can_update: ember.observer 'can.update', -> @set 'session.secure.switch_user', true if @get('can.update') == true

  no_addon:          ember.computed.not  'casespace.active_addon'
  switch_user:       ember.computed.bool 'session.can_switch_user'
  space_link_active: ember.computed.bool 'session.is_original_user'
  show_switch_user:  ember.computed.and  'switch_user', 'no_addon', 'current_space'

  c_switch_user:  ns.to_p 'toolbar', 'switch_user'
  t_user_actions: ns.to_t 'crumbs', 'user_actions'
  t_space:        ns.to_t 'crumbs', 'space'
  t_assignment:   ns.to_t 'crumbs', 'assignment'
  t_phase:        ns.to_t 'crumbs', 'phase'

  user_expansion_visible: false

  hide_all_expansions: -> @set('user_expansion_visible', false)

  actions:

    toggle_users: ->
      @toggleProperty('user_expansion_visible')
      return

    sign_out: -> @sendAction 'sign_out'

    hide_expansions: -> @hide_all_expansions()
