import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  unassigned_users: ember.computed.reads 'team_manager.current_unassigned_users'
  selected_user:    null
  all_data_loaded:  false

  # Components
  c_space_header:  ns.to_p 'space', 'header'
  c_team_snapshot: ns.to_p 'case_manager', 'team', 'snapshot'
  c_user_avatar:   ns.to_p 'common', 'user', 'avatar'
  c_loader:        ns.to_p 'common', 'shared', 'loader'
  
  # Routes
  r_teams_new:      ns.to_r 'case_manager', 'teams', 'new'
  r_team_sets:      ns.to_r 'case_manager', 'team_sets', 'index'
  r_team_sets_edit: ns.to_r 'case_manager', 'team_sets', 'edit'

  # Services
  team_manager: ember.inject.service()

  init: ->
    @_super()
    @get_team_users().then =>
      @set 'all_data_loaded', true  # Needed to avoid extra call for teams

  get_team_users: -> @get('team_manager').get_teams_for_team_set @get('model')

  actions:
    select_user:   (user) -> @set 'selected_user', user
    deselect_user: -> @set 'selected_user', null
