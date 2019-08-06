import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'

export default ember.View.extend

  tagName:           'ul'
  classNames:        ['team_users-user-list']
  classNameBindings: ['controller.selected_team:team_users-selectable-user']

  teams_visible:      true
  user_teams_visible: ember.observer 'controller.user_teams_visible', -> @set 'teams_visible', @get('controller.user_teams_visible')

  teams_sort_by: ['title']
  teams_sorted: ember.computed.sort 'filtered_teams', 'teams_sort_by'

  filtered_teams: ember.computed.intersect 'teams', 'controller.filtered_teams'

  teams: ember.computed 'team_users.@each', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('team_users').then (team_users) =>
        team_promises = team_users.getEach(ns.to_p 'team')
        ember.RSVP.Promise.all(team_promises).then (teams) => resolve teams
    ds.PromiseArray.create promise: promise

  team_users: ember.computed ->
    user_id = parseInt(@get 'user.id')
    @get('controller.store').filter ns.to_p('team_user'), (team_user) => team_user.get('user_id') == user_id

  # Show a user based on the filtered teams and the filter users value.
  show_user: ember.computed 'controller.filter_users', 'filtered_teams', ->
    user_filter = @get('controller.filter_users')
    return true unless user_filter
    length = @get('filtered_teams.length')
    switch user_filter
      when 'unassigned'
        length <= 0
      when 'assigned'
        length > 0
      else
        true

  actions:
    add_user: -> @get('controller').create_team_user(@get('controller.selected_team'), @get('user'))

    toggle_teams_visible: ->
      @toggleProperty 'teams_visible'
      false
