import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import totem_scope    from 'totem/scope'
import totem_messages from 'totem-messages/messages'

export default ember.Object.extend
  # ### Properties
  map:     null

  # ### Helpers
  clear:         -> @set 'map', null

  toString: -> 'GradebookMap' 

  # ###
  # ### Map helpers.
  # ###

  
  new_map: -> ember.Map.create()
  get_map: -> @get 'map'

  get_or_init_map: ->
    unless map = @get_map()
      @set 'map', @new_map()
      map = @get_map()
    map

  get_or_init_space_map: (space)           -> @get_or_init_record_map(space)
  get_or_init_assignment_map: (assignment) -> @get_or_init_record_map(assignment)

  get_or_init_phase_map: (assignment, phase) ->
    assignment_map = @get_or_init_assignment_map(assignment)
    phase_map      = assignment_map.get(phase)
    assignment_map.set phase, @new_map()  unless phase_map
    assignment_map.get(phase)

  get_or_init_record_map: (record) ->
    map       = @get_or_init_map()
    record_map = map.get(record)
    map.set record, @new_map() unless record_map
    map.get(record)

  # ###
  # ### Gradebook Users - all space users.
  # ###

  get_gradebook_users: (space, assignment) ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      space_map       = @get_or_init_space_map(space)
      gradebook_users = space_map.get 'gradebook_users'
      return resolve(gradebook_users) if ember.isPresent(gradebook_users)
      totem_scope.ownerable_to_current_user()
      query = totem_scope.get_view_query(assignment, sub_action: 'gradebook_users')
      totem_scope.add_authable_to_query(query)
      assignment.store.find(ns.to_p('assignment'), query).then =>
        space.get(ns.to_p 'users').then (users) =>
          gradebook_users = users.sortBy 'sort_name'
          space_map.set 'gradebook_users', gradebook_users
          resolve gradebook_users
    ds.PromiseArray.create promise: promise

  # ###
  # ### Gradebook Teams - all phase teams for an assignment.
  # ###

  get_gradebook_phase_teams: (assignment, team_phase) ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      phase_map = @get_or_init_phase_map(assignment, team_phase)
      teams     = phase_map.get 'teams'
      if teams
        resolve teams
      else
        query        = {}
        query.verb   = 'POST'
        query.action = 'view'
        query.data   = totem_scope.get_view_query(assignment, sub_action: 'gradebook_teams')
        query.model  = assignment
        query.id     = assignment.get('id')

        totem_scope.add_authable_to_query(query.data)
        ajax.object(query).then (payload) =>
          teams     = ajax.normalize_and_push_payload('team', payload)
          teams     = teams.uniq() if ember.isPresent(teams)
          phase_map = @get_or_init_phase_map(assignment, team_phase)
          phase_map.set 'teams', teams.sortBy('title')
          resolve @get_or_init_phase_map(assignment, team_phase).get 'teams'
    ds.PromiseArray.create promise: promise
