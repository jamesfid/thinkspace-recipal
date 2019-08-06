import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import totem_scope    from 'totem/scope'
import totem_messages from 'totem-messages/messages'

# Hold phase peer review users and teams.
# The 'peer_review' phase component is regenerated when the dock is regenerated
# e.g. a phase load.  Therefore, this will persist between
# phase view generates.
export default ember.Object.extend

  toString: -> 'PeerReviewPhaseMap'

  map: null

  clear: -> @set 'map', null

  # ###
  # ### Map helpers.
  # ###

  new_map: -> ember.Map.create()
  get_map: -> @get 'map'

  get_current_user: -> totem_scope.get_current_user()

  # The 'team_ownerable' is the original team ownerable selected as the 'current user'.
  # It is NOT the team selected by the peer review select team.
  # Once set, this team's viewerables are used to determine if a team can be viewed by
  # the original team for each phase.
  # A phase can have more/less viewerables than the initial phase.
  # If a user selects a peer review team on phase then changes to another phase where
  # the original team cannot view the peer review team, the peer review addon will exit
  # and the user will need to select a team as the 'current user'.
  get_team_ownerable: ->
    team_ownerable = @get 'team_ownerable'
    return team_ownerable  if team_ownerable
    @set 'team_ownerable', totem_scope.get_ownerable_record()
    @get 'team_ownerable'

  get_or_init_map: ->
    unless map = @get_map()
      @set 'map', @new_map()
      map = @get_map()
    map

  get_or_init_phase_map: (phase) ->
    map       = @get_or_init_map()
    phase_map = map.get(phase)
    map.set phase, @new_map() unless phase_map
    map.get(phase)

  get_or_init_ownerable_map: (phase, ownerable) ->
    phase_map     = @get_or_init_phase_map(phase)
    ownerable_map = phase_map.get(ownerable)
    phase_map.set ownerable, @new_map() unless ownerable_map
    phase_map.get(ownerable)

  # ###
  # ### Peer Review Users.
  # ###

  get_peer_review_users: (phase) ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      ownerable     = @get_current_user()
      ownerable_map = @get_or_init_ownerable_map(phase, ownerable)
      map_users     = ownerable_map.get('users')
      if ember.isPresent(map_users)
        resolve map_users
      else
        @request_peer_review_users(phase).then (users) =>
          sorted_users = users.without(ownerable).sortBy 'sort_name'
          ownerable_map.set 'users', sorted_users
          resolve sorted_users
        , (error) => reject(error)
    ds.PromiseArray.create promise: promise

  request_peer_review_users: (phase) ->
    new ember.RSVP.Promise (resolve, reject) =>
      totem_scope.ownerable_to_current_user()
      query = 
        model:      ns.to_p('team')
        verb:       'post'
        action:     'team_users_view'
        sub_action: 'peer_review_users'
      query = totem_scope.add_auth_to_ajax_query(query)
      ajax.object(query).then (payload) =>
        payload_users = payload[ns.to_p('users')] or []
        users         = phase.store.pushMany(ns.to_p('user'), payload_users)
        resolve users
      , (error) =>
        totem_messages.api_failure error, source: @, model: phase, action: 'peer_review_users'
        reject(error)

  # ###
  # ### Peer Review Teams.
  # ###

  get_peer_review_teams: (phase) ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      ownerable     = @get_team_ownerable()
      ownerable_map = @get_or_init_ownerable_map(phase, ownerable)
      map_teams     = ownerable_map.get('teams')
      if ember.isPresent(map_teams)
        resolve map_teams
      else
        @request_peer_review_teams(phase).then (teams) =>
          sorted_teams = teams.without(ownerable).sortBy 'title'
          ownerable_map.set 'teams', sorted_teams
          resolve sorted_teams
        , (error) => reject(error)
    ds.PromiseArray.create promise: promise

  request_peer_review_teams: (phase) ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      query = 
        model:      ns.to_p('team')
        verb:       'post'
        action:     'teams_view'
        sub_action: 'peer_review_teams'
      query = totem_scope.add_auth_to_ajax_query(query)
      ajax.object(query).then (payload) =>
        payload_teams = payload[ns.to_p('teams')] or []
        teams         = phase.store.pushMany(ns.to_p('team'), payload_teams)
        resolve teams
      , (error) =>
        totem_messages.api_failure error, source: @, model: phase, action: 'peer_review_teams'
        reject(error)
    return ds.PromiseArray.create promise: promise
