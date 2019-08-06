import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-team/controllers/base'

import team_view      from './team/view'
import team_user_view from './team_user/view'
import user_view      from './user/view'
import user_team_view from './user_team/view'

export default base.extend
  users_team_view:      team_view
  users_team_user_view: team_user_view
  users_user_view:      user_view
  users_user_team_view: user_team_view

  filter_users:       null
  user_teams_visible: true
  resource_users:     ember.computed -> @get('all_team_users')

  selected_team:  null
  filtered_teams: ember.computed.reads 'all_teams_filtered_by_category'

  actions:
    # Filter teams.
    filter_by_collaboration_teams: -> @set_team_filter_category @get('collaboration_category')
    filter_by_peer_review_teams:   -> @set_team_filter_category @get('peer_review_category')
    filter_teams_off:              -> @set_team_filter_category()
    # Filter users.
    filter_by_unassigned_users: -> @set_filter_users 'unassigned'
    filter_by_assigned_users:   -> @set_filter_users 'assigned'
    filter_users_off:           -> @set_filter_users()

    toggle_user_teams_visible: ->
      @toggleProperty 'user_teams_visible'
      false

    select_team: (team) -> @set 'selected_team', team

  set_filter_users: (filter_by=null) -> @set 'filter_users', filter_by

  set_team_filter_category: (category) ->
    @set_filter_users()
    @_super(category)

  create_team_user: (team, user) ->
    @totem_error.throw @, "remove team user team is blank."  unless team
    @totem_error.throw @, "remove team user user is blank."  unless user
    return unless ember.isBlank @get_team_users(team, user)
    team_user = @store.createRecord ns.to_p('team_user'),
      team_id: parseInt(team.get 'id')
      user_id: parseInt(user.get 'id')
    team_user.set common.to_p('user'), user
    team_user.set ns.to_p('team'), team
    team_user.save().then =>
      @totem_messages.api_success source: @, model: team_user, action: 'create', i18n_path: ns.to_o('team_user', 'save')
    , (error) =>
      @totem_messages.api_failure error, source: @, model: team_user, action: 'create'

  delete_team_user: (team, user) ->
    @totem_error.throw @, "remove team user team is blank."  unless team
    @totem_error.throw @, "remove team user user is blank."  unless user
    @get_team_users(team, user).forEach (team_user) =>
      team_user.deleteRecord()
      team_user.save().then =>
        @totem_messages.api_success source: @, model: team_user, action: 'delete', i18n_path: ns.to_o('team_user', 'destroy')
      , (error) =>
        @totem_messages.api_failure error, source: @, model: team_user, action: 'delete'

  get_team_users: (team, user) ->
    team_id = parseInt(team.get 'id')
    user_id = parseInt(user.get 'id')
    @store.all(ns.to_p 'team_user').filter (team_user) => team_user.get('team_id') == team_id and team_user.get('user_id') == user_id
