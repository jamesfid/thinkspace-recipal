import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'

export default ember.View.extend

  tagName:           'ul'
  classNames:        ['team_viewers-team-list']
  classNameBindings: ['is_selected_team:team_viewers-selected-team']

  is_selected_team: ember.computed 'controller.selected_team', -> @get('review_team') == @get('controller.selected_team')

  has_team_viewers: ember.computed.gt 'teams_sorted.length', 0
  has_user_viewers: ember.computed.gt 'users_sorted.length', 0

  viewers_visible:      true
  team_viewers_visible: ember.observer 'controller.team_viewers_visible', -> @set 'viewers_visible', @get('controller.team_viewers_visible')

  teams_sorted: ember.computed 'team_viewerables', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('team_viewerables').then (teams) => resolve teams.sortBy 'title'
    ds.PromiseArray.create promise: promise

  team_viewerables: ember.computed 'team_viewers.@each', ->
    new ember.RSVP.Promise (resolve, reject) =>
      team_path = ns.to_p('team')
      @get('team_viewers').then (team_viewers) =>
        team_team_viewers = team_viewers.filter (team_viewer) => @polymorphic_type_to_path(team_viewer.get 'viewerable_type') == team_path
        team_promises = team_team_viewers.getEach('viewerable')
        ember.RSVP.Promise.all(team_promises).then (teams) => resolve teams

  users_sorted: ember.computed 'user_viewerables', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('user_viewerables').then (users) => resolve users.sortBy 'sort_name'
    ds.PromiseArray.create promise: promise

  user_viewerables: ember.computed 'team_viewers.@each', ->
    new ember.RSVP.Promise (resolve, reject) =>
      user_path = common.to_p('user')
      @get('team_viewers').then (team_viewers) =>
        user_team_viewers = team_viewers.filter (team_viewer) => @polymorphic_type_to_path(team_viewer.get 'viewerable_type') == user_path
        user_promises = user_team_viewers.getEach('viewerable')
        ember.RSVP.Promise.all(user_promises).then (users) => resolve users

  team_viewers: ember.computed ->
    team_id = parseInt(@get 'review_team.id')
    @get('controller.store').filter ns.to_p('team_viewer'), (team_viewer) => team_viewer.get('team_id') == team_id

  polymorphic_type_to_path: (type) -> @get('controller').polymorphic_type_to_path(type)

  actions:
    toggle_viewers_visible: ->
      @toggleProperty 'viewers_visible'
      false
