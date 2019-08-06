import ember          from 'ember'
import ns             from 'totem/ns'
import ajax           from 'totem/ajax'
import totem_scope    from 'totem/scope'
import totem_messages from 'totem-messages/messages'

export default ember.Object.extend

  toString: -> 'PhaseManagerMap'

  ownerable_phase_values: null

  get_ownerable:    -> totem_scope.get_ownerable_record()
  get_current_user: -> totem_scope.get_current_user()

  # ###
  # ### Set Map.
  # ###

  has_ownerable_phase_states: (assignment) -> @get_or_init_ownerable_map().get(assignment) == true

  set_map_without_phase_states: (assignment) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @set_ownerable_phase_map(assignment, {}).then => resolve()

  set_map: (assignment) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if @has_ownerable_phase_states(assignment)
        @reset_ownerable_phase_states(assignment).then => resolve()
      else
        query = 
          model:  assignment
          id:     assignment.get('id')
          action: 'phase_states'
          data:   {}
        totem_scope.add_ownerable_to_query(query.data)
        ajax.object(query).then (payload) =>
          @set_ownerable_phase_map(assignment, payload).then =>
            @get_or_init_ownerable_map().set assignment, true
            resolve()

  set_ownerable_phase_map: (assignment, payload) ->
    new ember.RSVP.Promise (resolve, reject) =>
      # assignment.store.pushPayload(payload)  # will add all users, teams, scores, states
      @push_phase_state_metadata_in_store(assignment, payload)
      phases       = @push_association_in_store(assignment, payload, 'phase')
      phase_states = @push_association_in_store(assignment, payload, 'phase_state')
      phase_scores = @push_association_in_store(assignment, payload, 'phase_score')
      phases.forEach (phase) =>
        phase_map              = @get_or_init_ownerable_phase_map(phase)
        phase_states_for_phase = @get_phase_states_for_phase(phase, phase_states)
        phase_map.set 'phase_states', phase_states_for_phase
        phase_map.set 'selected_phase_state', @get_selected_phase_state_for_ownerable(phase, phase_states_for_phase)
      resolve()

  get_selected_phase_state_for_ownerable: (phase, phase_states) ->
    if @ownerable_has_multiple_phase_states(phase)
      if phase.is_team_ownerable()
        filtered = @filter_phase_states_by_is_team_ownerable(phase_states, true)
        # If they have user states, but no team states, return user states anyway.
        filtered = phase_states if filtered.get('length') == 0 and phase_states.get('length') > 0
        filtered.get('firstObject')
      else
        filtered = @filter_phase_states_by_is_team_ownerable(phase_states, false)
        filtered.get('firstObject')
    else
      phase_states.get('firstObject') 

  filter_phase_states_by_is_team_ownerable: (phase_states, is_team_ownerable) ->
    phase_states.filter (phase_state) => phase_state.is_team_ownerable() == is_team_ownerable

  get_phase_states_for_phase: (phase, phase_states) ->
    phase_id     = parseInt(phase.get 'id')
    phase_states = (phase_states.filter (state) => state.get('phase_id') == phase_id).sortBy('title')
    if phase.is_team_ownerable()
      filtered_team = @filter_phase_states_by_is_team_ownerable(phase_states, true)
      filtered_user = @filter_phase_states_by_is_team_ownerable(phase_states, false)
      if filtered_team.get('length') == 0 and filtered_user.get('length') > 0
        filtered_user
      else
        filtered_team
    else
      phase_states


  push_association_in_store: (assignment, payload, association) ->
    type    = ns.to_p(association)
    records = payload[type.pluralize()]
    return [] if ember.isBlank(records)
    norm_records = records.map (record) => assignment.store.normalize(type, record)
    assignment.store.pushMany(type, norm_records)

  push_phase_state_metadata_in_store: (assignment, payload) ->
    type    = ns.to_p('metadata')
    records = payload[type]
    return [] if ember.isBlank(records)
    norm_records = records.map (record) => assignment.store.normalize(type, record)
    assignment.store.pushMany(type, norm_records)

  # ###
  # ### Reset Phase States from Map.
  # ###

  reset_ownerable_phase_states: (assignment) ->
    new ember.RSVP.Promise (resolve, reject) =>
      assignment.get(ns.to_p 'phases').then (phases) =>
        phase_state_association_promises = phases.getEach(ns.to_p 'phase_states')
        ember.RSVP.Promise.all(phase_state_association_promises).then (phase_state_associations) =>
          phases.forEach (phase, index) =>
            phase_states       = @get_ownerable_phase_states(phase) or []
            phase_phase_states = phase_state_associations.objectAt(index)
            phase_states.forEach (phase_state) =>
              phase_phase_states.pushObject(phase_state)  unless phase_phase_states.contains(phase_state)
          resolve()

  # ###
  # ### Ownerable Get/Set.
  # ###

  get_current_user_phase_states: (phase) -> 
    phase_states = ember.makeArray(@get_current_user_phase_map(phase).get 'phase_states')
    # ### TODO: Does this make sense? PHASESTATEFIX
    #return ember.makeArray(phase_states) if ember.isPresent(phase_states) and phase_states.get('length') == 1
    #if phase.is_team_ownerable()
    #  phase_states = phase_states.filter (phase_state) => phase_state.is_team_ownerable()
    ember.makeArray(phase_states)

  get_ownerable_phase_states: (phase)    -> 
    phase_states = @get_or_init_ownerable_phase_map(phase).get 'phase_states'
    ember.makeArray(phase_states)

  set_global_selected_phase_state: (phase_state) -> @get_or_init_ownerable_map().set 'global_selected_phase_state', phase_state
  get_global_selected_phase_state:               -> @get_or_init_ownerable_map().get 'global_selected_phase_state'

  set_phase_selected_phase_state: (phase, phase_state) -> @get_or_init_ownerable_phase_map(phase).set 'selected_phase_state', phase_state
  get_phase_selected_phase_state: (phase)              -> @get_or_init_ownerable_phase_map(phase).get 'selected_phase_state'

  ownerable_has_multiple_phase_states: (phase) -> (@get_ownerable_phase_states(phase) or []).get('length') > 1

  # ###
  # ### Find by any Ownerable (will not init any maps).
  # ###

  find_ownerable_phase_states:         (phase, ownerable) -> @find_ownerable_phase_map_value(phase, ownerable, 'phase_states') or []
  find_ownerable_selected_phase_state: (phase, ownerable) -> @find_ownerable_phase_map_value(phase, ownerable, 'selected_phase_state')

  find_ownerable_phase_map_value: (phase, ownerable, key) ->
    map = @get_or_init_map()
    ownerable_map = map.get(ownerable)
    return null unless ownerable_map
    phase_map = ownerable_map.get(phase)
    return null unless phase_map
    phase_map.get(key)

  find_phase_state_ownerable_in_phase_states: (phase_state, phase_states) ->
    return null unless phase_state
    return null if ember.isBlank(phase_states)
    id   = phase_state.get('ownerable_id')
    type = phase_state.get('ownerable_type')
    phase_states.find (state) => id == state.get('ownerable_id') and type == state.get('ownerable_type')

  # ###
  # ### Base Map Getters.
  # ###

  new_map: -> ember.Map.create()
  get_map: -> @get('ownerable_phase_values')

  get_or_init_map: ->
    map = @get_map()
    unless map
      @set 'ownerable_phase_values', @new_map()
      map = @get_map()
    map

  get_or_init_ownerable_map: (ownerable=null) ->
    map           = @get_or_init_map()
    ownerable    ?= @get_ownerable()
    ownerable_map = map.get(ownerable)
    unless ownerable_map
      map.set ownerable, @new_map()
      ownerable_map = map.get(ownerable)
    ownerable_map

  get_or_init_ownerable_phase_map: (phase, ownerable=null) ->
    ownerable_map = @get_or_init_ownerable_map(ownerable)
    phase_map = ownerable_map.get(phase)
    unless phase_map
      ownerable_map.set phase, @new_map()
      phase_map = ownerable_map.get(phase)
    phase_map

  get_current_user_phase_map: (phase) ->
    @get_or_init_ownerable_phase_map phase, @get_current_user()
