import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  title:          ember.computed -> (@get('team_ownerable') and @get('group_values.team_label')) or @get('group_values.user_label') or @get('group_values.label')
  current_state:  ember.computed.reads 'group_values.state'
  team_ownerable: ember.computed.reads 'group_values.team_ownerable'
  can_edit:       ember.computed.and   'is_edit', 'group_values.state_id'

  edit_state_visible: false

  new_state: null

  domain_phase_states: [
    {state: 'unlocked',  title: 'Unlock'},
    {state: 'locked',    title: 'Lock'},
    {state: 'completed', title: 'Complete'},
  ]

  actions:

    change: (phase_state) ->
      @set 'edit_state_visible', false
      @sendAction 'save_state', @get('group_values'), phase_state

    cancel: ->
      @set 'edit_state_visible', false

    toggle_edit: ->
      @toggleProperty('edit_state_visible')
      return
