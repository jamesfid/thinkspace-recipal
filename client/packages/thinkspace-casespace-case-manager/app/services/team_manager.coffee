import ember from 'ember'
import ajax  from 'totem/ajax'
import ns    from 'totem/ns'
import util from 'totem/util'
import ta from 'totem/ds/associations'
import totem_scope from 'totem/scope'

export default ember.Object.extend
  # Properties
  space_loaded_map:                null
  team_set_loaded_map:             null
  current_space:                   null
  current_team_set:                null
  current_unassigned_users_loaded: false

  current_users: ember.computed 'current_space', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      space = @get 'current_space'
      console.warn "Current users called with: ", space
      return resolve([]) unless ember.isPresent(space)
      space.get(ns.to_p('users')).then (users) =>
        resolve(users)
    ta.PromiseArray.create promise: promise

  current_unassigned_users: ember.computed 'current_team_set', ->
    console.log "[team-manager] Unassigned users fired.", @get('current_space'), @get('current_team_set')
    promise = new ember.RSVP.Promise (resolve, reject) =>
      team_set = @get 'current_team_set'
      team_set.get('unlocked_teams').then (teams) =>
        team_user_promises = teams.mapBy(ns.to_p('team_users'))
        ember.RSVP.all(team_user_promises).then (team_user_arrays) =>
          team_users = []
          team_user_arrays.forEach (team_user_array) => team_user_array.forEach (team_user) => team_users.pushObject(team_user)
          assigned_user_ids = util.string_array_to_numbers team_users.mapBy('user_id')
          space = @get 'current_space'
          space.get(ns.to_p('users')).then (users) =>
            user_ids = util.string_array_to_numbers users.mapBy('id')
            filter   = @get_store().filter ns.to_p('user'), (user) =>
              id = parseInt user.get('id')
              !assigned_user_ids.contains(id) and user_ids.contains(id)
            team_set.set_unassigned_users_filter(filter) # Set to keep track of count after metadata is loaded.
            resolve(filter)
    ta.PromiseArray.create promise: promise

  update_unassigned_users: -> @propertyDidChange 'current_unassigned_users'
  get_store: ->  @container.lookup('store:main')
  set_team_set: (team_set) -> @set 'current_team_set', team_set
  set_team_set_and_space: (team_set) ->
    new ember.RSVP.Promise (resolve, reject) =>
      team_set.get('space').then (space) =>
        @get_teams_for_team_set(team_set).then =>
          @set 'current_space', space
          @set 'current_unassigned_users_loaded', true # Needed so that templates can scope to this to not pre-fire this before the AJAXs are done.
          @set_team_set(team_set)
          resolve(team_set)

  # Ajax
  teams_ajax: (model, type, action, verb, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query = 
        model:  model
        id:     model.get 'id'
        action: action
        verb:   verb
      ajax.object(query).then (payload) =>
        records = ajax.normalize_and_push_payload(type, payload, options)
        resolve(records)

  set_space_roster: (space) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @set 'current_space', space
      return resolve() if @is_space_loaded(space)
      @teams_ajax(space, 'user', 'roster', 'get').then (records) =>
        @set_space_loaded(space)
        resolve()

  get_space_from_params: (params) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_store().find(ns.to_p('space'), params.space_id).then (space) =>
        @set 'current_space', space
        @set_space_roster(space).then => resolve(space)

  get_team_set_from_params: (params) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_store().find(ns.to_p('team_set'), params.team_set_id).then (team_set) =>
        team_set.get('space').then (space) =>
          @set 'current_space', space
          @set_team_set team_set
          resolve(team_set)

  get_teams_for_team_set: (team_set) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if @is_team_set_loaded(team_set)
      @teams_ajax(team_set, 'team', 'teams', 'get').then (records) =>
        @set_team_set_loaded(team_set)
        resolve(records)

  # Map loaded getter/setters
  get_loaded_map: (type) ->
    key = "#{type}_loaded_map"
    map = @get type
    unless ember.isPresent(map)
      map = ember.Map.create()
      @set type, map
    map

  set_loaded: (type, record) ->
    map = @get_loaded_map(type)
    map.set record, is_loaded: true

  reset_loaded: (type, record) ->
    map = @get_loaded_map(type)
    map.set record, is_loaded: false

  is_map_loaded: (type, record) ->
    map = @get_loaded_map type
    return false unless ember.isPresent(map)
    value = map.get record
    return false unless ember.isPresent(value)
    value.is_loaded

  get_team_set_loaded_map: -> @get_loaded_map 'team_set'
  get_space_loaded_map:    -> @get_loaded_map 'space'
  set_team_set_loaded:     (team_set) -> @set_loaded 'team_set', team_set
  reset_team_set_loaded:   (team_set) -> @reset_loaded 'team_set', team_set
  set_space_loaded:        (space) -> @set_loaded 'space', space
  reset_space_loaded:      (space) -> @reset_loaded 'space', space
  is_space_loaded:         (space) -> @is_map_loaded 'space', space
  is_team_set_loaded:      (team_set) -> @is_map_loaded 'team_set', team_set

  # Transitions
  get_route: -> @container.lookup('route:application')
  transition_to_team_show: (team) -> @get_route().transitionTo ns.to_r('case_manager', 'teams', 'edit'), team
  transition_to_team_set_show: (team) -> 
    team.get('team_set').then (team_set) =>
      @get_route().transitionTo ns.to_r('case_manager', 'team_sets', 'show'), team_set.get('space'), team_set

  # Helpers for team components
  team_users_for_team: (team) ->
    store = @get_store()
    store.filter ns.to_p('team_user'), (team_user) =>
      id      = parseInt team.get('id')
      team_id = parseInt team_user.get('team_id')
      @propertyDidChange 'current_unassigned_users'
      id == team_id