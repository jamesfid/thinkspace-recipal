import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'

export default ember.View.extend

  tagName:           'ul'
  classNames:        ['team_assign-resource-list']
  classNameBindings: ['is_selected_resource:team_assign-selected-resource']

  is_selected_resource: ember.computed 'controller.selected_resource', -> @get('resource') == @get('controller.selected_resource')

  teams_visible:          true
  resource_teams_visible: ember.observer 'controller.resource_teams_visible', -> @set 'teams_visible', @get('controller.resource_teams_visible')

  resource_teams: ember.computed 'resource_teamables.@each', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('resource_teamables').then (teamables) =>
        team_promises = teamables.getEach('team')
        ember.RSVP.Promise.all(team_promises).then (teams) =>
          resolve teams.sortBy 'title'
    ds.PromiseArray.create promise: promise

  resource_teamables: ember.computed ->
    resource   = @get('resource')
    controller = @get('controller')
    @get('controller.store').filter ns.to_p('team_teamable'), (team_teamable) => controller.record_is_polymorphic(resource, team_teamable, 'teamable')

  actions:
    toggle_teams_visible: ->
      @toggleProperty 'teams_visible'
      false
