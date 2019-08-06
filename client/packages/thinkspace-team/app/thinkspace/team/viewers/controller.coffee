import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import base  from 'thinkspace-team/controllers/base'

import team_view        from './team/view'
import team_team_view   from './team_team/view'
import team_user_view   from './team_user/view'
import team_viewer_view from './team_viewer/view'
import user_viewer_view from './user_viewer/view'

export default base.extend
  viewers_team_view:        team_view
  viewers_team_team_view:   team_team_view
  viewers_team_user_view:   team_user_view
  viewers_user_viewer_view: user_viewer_view
  viewers_team_viewer_view: team_viewer_view

  teams_visible: false
  users_visible: false

  team_viewers_visible: true

  selected_team: null

  resource_users: ember.computed -> @get('all_team_users')

  filtered_teams: ember.computed.reads 'all_collaboration_teams'

  team_viewers: ember.computed 'selected_team', 'filtered_teams.@each', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      selected = @get('selected_team')
      @get('filtered_teams').then (teams) =>
        resolve teams.reject (team) => team == selected
    ds.PromiseArray.create promise: promise

  is_viewer_assigned: (review_team, viewer) ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      review_team.get(ns.to_p 'team_viewers').then (viewerables) =>
        resolve viewerables.find (viewerable) => @record_is_polymorphic(viewer, viewerable, 'viewerable')
    ds.PromiseObject.create promise: promise

  actions:
    select_team: (team) -> @set_selected_team(team)

    show_teams: -> @set 'teams_visible', true
    hide_teams: -> @set 'teams_visible', false
    show_users: -> @set 'users_visible', true
    hide_users: -> @set 'users_visible', false

    toggle_team_viewers_visible: ->
      @toggleProperty 'team_viewers_visible'
      false

  set_selected_team: (team) ->
    @set 'selected_team', team
    @send 'show_teams'

  create_team_viewer: (team, viewer) ->
    @totem_error.throw @, "create team viewer team is blank."    unless team
    @totem_error.throw @, "create team viewer viewer is blank."  unless viewer
    return unless ember.isBlank @get_team_viewers(team, viewer)
    team_viewer = @store.createRecord ns.to_p('team_viewer'),
      team_id:         parseInt(team.get 'id')
      viewerable_type: @totem_scope.get_record_path(viewer)
      viewerable_id:   parseInt(viewer.get 'id')
    team_viewer.set ns.to_p('team'), team
    team_viewer.save().then =>
      @totem_messages.api_success source: @, model: team_viewer, action: 'create', i18n_path: ns.to_o('team_viewer', 'save')
    , (error) =>
      @totem_messages.api_failure error, source: @, model: team_viewer, action: 'create'

  delete_team_viewer: (team, viewer) ->
    @totem_error.throw @, "remove team viewer team is blank."    unless team
    @totem_error.throw @, "remove team viewer viewer is blank."  unless viewer
    @get_team_viewers(team, viewer).forEach (team_viewer) =>
      team_viewer.deleteRecord()
      team_viewer.save().then =>
        @totem_messages.api_success source: @, model: team_viewer, action: 'delete', i18n_path: ns.to_o('team_viewer', 'destroy')
        @remove_from_association(team, team_viewer)
      , (error) =>
        @totem_messages.api_failure error, source: @, model: team_viewer, action: 'delete'

  get_team_viewers: (team, viewer) ->
    team_id = parseInt(team.get 'id')
    @store.all(ns.to_p 'team_viewer').filter (team_viewer) =>
      team_viewer.get('team_id') == team_id and @record_is_polymorphic(viewer, team_viewer, 'viewerable')

  remove_from_association: (team, team_viewer) ->
    team.get(ns.to_p 'team_viewers').then (team_viewers) => team_viewers.removeObject(team_viewer)