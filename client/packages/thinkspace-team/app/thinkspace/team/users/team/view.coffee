import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'

export default ember.View.extend

  tagName:           'ul'
  classNames:        ['team_users-team-list']
  classNameBindings: ['is_selected_team:team_users-selected-team']

  is_selected_team: ember.computed 'controller.selected_team', -> @get('team') == @get('controller.selected_team')

  users_sorted: ember.computed 'users', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('users').then (users) => resolve users.sortBy 'sort_name'
    ds.PromiseArray.create promise: promise

  users: ember.computed 'team_users.@each', ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get('team_users').then (team_users) =>
        user_promises = team_users.getEach(common.to_p 'user')
        ember.RSVP.Promise.all(user_promises).then (users) => resolve users

  team_users: ember.computed ->
    team_id = parseInt(@get 'team.id')
    @get('controller.store').filter ns.to_p('team_user'), (team_user) => team_user.get('team_id') == team_id
