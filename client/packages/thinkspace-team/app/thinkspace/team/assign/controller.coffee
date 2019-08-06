import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-team/controllers/base'

import team_view          from './team/view'
import resource_view      from './resource/view'
import resource_team_view from './resource_team/view'

export default base.extend
  assign_team_view:          team_view
  assign_resource_view:      resource_view
  assign_resource_team_view: resource_team_view

  resources: ember.computed.reads 'parentController.resources'

  resource_teams_visible: true
  team_users_visible:     false
  selected_resource:      null

  filtered_teams: ember.computed.reads 'all_teams_filtered_by_category'

  actions:
    select_resource: (resource) ->
      return unless resource
      if resource.get('team_ownerable')
        @set_team_filter_category @get 'collaboration_category'
      else
        @set_team_filter_category @get 'peer_review_category'
      @set 'selected_resource', resource

    toggle_resource_teams_visible: ->
      @toggleProperty 'resource_teams_visible'
      false

    toggle_team_users_visible: ->
      @toggleProperty 'team_users_visible'
      false

  get_resource_teams: (resource) ->
    new ember.RSVP.Promise (resolve, reject) =>
      teamables = @get_resource_team_teamables(resource)
      team_promises = teamables.getEach(ns.to_p 'team')
      ember.RSVP.Promise.all(team_promises).then (teams) =>
        resolve teams.sortBy('title')
    
  get_resource_team_teamables: (resource) ->
    @store.all(ns.to_p 'team_teamable').filter (team_teamable) => @record_is_polymorphic(resource, team_teamable, 'teamable')

  create_team_teamable: (team, resource) ->
    @totem_error.throw @, "create team teamable team is blank."      unless team
    @totem_error.throw @, "create team teamable resource is blank."  unless resource
    return unless ember.isBlank @get_team_teamables(team, resource)
    team_teamable = @store.createRecord ns.to_p('team_teamable'),
      team_id:       parseInt(team.get 'id')
      teamable_type: @totem_scope.get_record_path(resource)
      teamable_id:   parseInt(resource.get 'id')
    team_teamable.set ns.to_p('team'), team
    team_teamable.save().then =>
      @totem_messages.api_success source: @, model: team_teamable, action: 'create'
    , (error) =>
      @totem_messages.api_failure error, source: @, model: team_teamable, action: 'create'

  delete_team_teamable: (team, resource) ->
    @totem_error.throw @, "remove team teamable team is blank."      unless team
    @totem_error.throw @, "remove team teamable resource is blank."  unless resource
    @get_team_teamables(team, resource).forEach (team_teamable) =>
      team_teamable.deleteRecord()
      team_teamable.save().then =>
        @totem_messages.api_success source: @, model: team_teamable, action: 'delete'
        @remove_from_association(team, team_teamable)
      , (error) =>
        @totem_messages.api_failure error, source: @, model: team_teamable, action: 'delete'

  get_team_teamables: (team, resource) ->
    team_id = parseInt(team.get 'id')
    @store.all(ns.to_p 'team_teamable').filter (team_teamable) =>
       team_teamable.get('team_id') == team_id and @record_is_polymorphic(resource, team_teamable, 'teamable')

  remove_from_association: (team, team_teamable) ->
    team.get(ns.to_p 'team_teamables').then (team_teamables) => team_teamables.removeObject(team_teamable)