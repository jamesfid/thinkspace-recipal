import ember from 'ember'
import ta from 'totem/ds/associations'
import ajax from 'totem/ajax'

export default ta.Model.extend ta.add(
    ta.has_many 'users'
    ta.has_many 'users', type: ta.to_p('owner'), reads: {name: 'owners'}
    ta.has_many 'space_types', reads: {}
    ta.has_many 'assignments', reads: [{sort: 'title'}, {name: 'assignments_due_at_asc', sort: ['due_at:asc', 'title:asc']}]
    ta.has_many 'team_sets', reads: {}
  ), 
  title:     ta.attr('string')

  immediate_assignment: ember.computed.reads 'assignments_due_at_asc.firstObject'
  active_assignments:   ember.computed.filterBy 'assignments_due_at_asc', 'active', true
  inactive_assignments: ember.computed.filterBy 'assignments_due_at_asc', 'active', false
  valid_roles:          ['read', 'update', 'owner']

  get_team_sets: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query =
        model:  ta.to_p 'space'
        verb:   'get'
        action: 'team_sets'
        id:     @get 'id'
      ajax.object(query).then (payload) =>
        team_sets = ajax.normalize_and_push_payload 'team_set', payload
        team_sets = team_sets.filter (team_set) => team_set.get('unlocked_states').contains team_set.get('state') unless options.include_locked
        resolve(team_sets)
    , (error) => console.error "[space model] Error in get_team_sets.", error

  unlocked_team_sets: ember.computed 'team_sets', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('team_sets').then (team_sets) =>
        records = team_sets.filter (team_set) => team_set.get('unlocked_states').contains team_set.get('state')
        resolve(records)
    ta.PromiseArray.create promise: promise

  locked_team_sets: ember.computed 'team_sets', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('team_sets').then (team_sets) =>
        records = team_sets.filter (team_set) => team_set.get('locked_states').contains team_set.get('state')
        resolve(records)
    ta.PromiseArray.create promise: promise

  add_ability: (abilities) ->
    update            = abilities.update or false
    abilities.update  = update
    abilities.destroy = update
