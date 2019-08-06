import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  casespace:     ember.inject.service()
  phase_manager: ember.inject.service()

  # ### Properties
  tagName:                 ''
  is_selecting_ownerable:  false
  has_ownerable_generated: false

  # ### Computed properties
  addon_ownerable:    ember.computed.reads 'casespace.active_addon_ownerable'
  model:              ember.computed.reads 'casespace.current_phase'
  current_phase:      ember.computed.reads 'casespace.current_phase'
  current_assignment: ember.computed.reads 'casespace.current_assignment'

  # ### Components
  c_ownerable_selector: ns.to_p 'casespace', 'ownerable', 'selector'

  # ### Helpers
  get_is_team_collaboration: ->
    id = @get 'model.team_category_id'
    return false unless ember.isPresent(id)
    id == 2 # Team Collaboration is 2

  set_addon_ownerable: (ownerable) ->
    @totem_error.throw @, "Change to ownerable is blank."  unless ownerable
    @totem_scope.view_only_on()
    @get('phase_manager').mock_phase_states_on() unless @get 'is_gradebook'
    @get('phase_manager').set_addon_ownerable_and_generate_view(ownerable).then =>
      @callback_set_addon_ownerable() if typeof @['callback_set_addon_ownerable'] == 'function'

  set_addon_ownerable_from_offset: (offset) ->
    ownerable = @get 'addon_ownerable'
    @get('ownerables').then (ownerables) =>
      if ember.isPresent(ownerable)
        index = ownerables.indexOf(ownerable)
        return if index == -1
        new_ownerable = ownerables.objectAt(index + offset)
      else
        new_ownerable = ownerables.get('firstObject')
      return unless ember.isPresent(new_ownerable)
      @set_addon_ownerable(new_ownerable)

  actions:
    set_is_selecting_ownerable:    -> @set 'is_selecting_ownerable', true
    reset_is_selecting_ownerable:  -> @set 'is_selecting_ownerable', false
    toggle_is_selecting_ownerable: -> @toggleProperty 'is_selecting_ownerable'
    select_ownerable: (ownerable)  -> @set_addon_ownerable(ownerable)
    select_next_ownerable:         -> @set_addon_ownerable_from_offset(1)
    select_previous_ownerable:     -> @set_addon_ownerable_from_offset(-1)