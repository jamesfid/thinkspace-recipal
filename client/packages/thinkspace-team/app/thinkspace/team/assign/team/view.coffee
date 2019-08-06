import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'

export default ember.View.extend

  tagName:           'li'
  classNames:        ['team_assign-teams-list-team']
  attributeBindings: ['title']

  title: ember.computed -> "Add/remove team from '#{@get('controller.selected_resource.title')}'"

  is_team_assigned: ember.computed "team.#{ns.to_prop('team_teamables', '@each')}", ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get_controller().get_resource_teams(@get_resource()).then (teams) =>
        resolve teams.contains(@get_team())
    ds.PromiseObject.create promise: promise

  users_visible:      false
  team_users_visible: ember.observer 'controller.team_users_visible', -> @set 'users_visible', @get('controller.team_users_visible')

  team_users: ember.computed "team.#{ns.to_prop('team_users', '@each')}", ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get_team().get(ns.to_p 'team_users').then (team_users) =>
        user_promises = team_users.getEach(common.to_p 'user')
        ember.RSVP.Promise.all(user_promises).then (users) =>
          resolve users.sortBy 'sort_name'
    ds.PromiseArray.create promise: promise

  get_team:       -> @get 'team'
  get_resource:   -> @get 'controller.selected_resource'
  get_controller: -> @get 'controller'

  actions:
    add_team:    -> @get_controller().create_team_teamable(@get_team(), @get_resource())
    remove_team: -> @get_controller().delete_team_teamable(@get_team(), @get_resource())

    toggle_users_visible: ->
      @toggleProperty 'users_visible'
      false

