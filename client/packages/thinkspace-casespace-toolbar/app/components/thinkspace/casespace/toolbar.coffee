import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Services
  thinkspace: ember.inject.service()
  casespace:  ember.inject.service()
  
  # ### Properties
  tagName:                ''
  user_expansion_visible: false
  is_user_profile: false

  totem_data_config: ability: {ajax_source: ns.to_p('spaces')}

  # Switch User Properties
  current_space:    ember.computed.reads 'casespace.current_space'
  no_addon:         ember.computed.not   'casespace.active_addon'
  switch_user:      ember.computed.bool  'session.can_switch_user'
  show_switch_user: ember.computed.and   'switch_user', 'no_addon', 'current_space'

  # ### Components
  c_switch_user:   ns.to_p('toolbar', 'switch_user')
  c_ownerable_bar: ns.to_p 'casespace', 'ownerable', 'bar'

  # ### Observers
  # Set in the session data whether the signed in user can switch users.
  # This does NOT persist accross page reloads, but the switch-authenticator will set this to true.
  observe_can_update: ember.observer 'can.update', -> 
    if @get('can.update') and @get('casespace.current_assignment.can.update')
      @set 'session.secure.switch_user', true 

  hide_all_expansions: -> @set('user_expansion_visible', false)
  
  actions:
    toggle_support: ->
      @set 'support_button_pressed', true
      @toggleProperty 'is_support_visible'

    hide_expansions: -> @hide_all_expansions()
    sign_out:        -> @totem_messages.sign_out_user()
    toggle_users:    ->
      @toggleProperty('user_expansion_visible')
      return

    transition_to_profile: -> @transitionToRoute('users.show.profile', @get('session.current_user'))
