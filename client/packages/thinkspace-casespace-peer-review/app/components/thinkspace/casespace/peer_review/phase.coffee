import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  phase_manager:         ember.inject.service()
  casespace_peer_review: ember.inject.service()

  t_header:      ns.to_t 'peer_review', 'phase', 'header'
  t_footer:      ns.to_t 'peer_review', 'phase', 'footer'
  t_team_select: ns.to_t 'peer_review', 'phase', 'team_select'
  t_user_select: ns.to_t 'peer_review', 'phase', 'user_select'

  current_phase:   ember.computed.reads 'dock.current_phase'
  addon_ownerable: ember.computed.reads 'dock.addon_ownerable'

  select_user_prompt: 'Select a Student'
  select_team_prompt: 'Select a Team'

  select_visible: false # used to toggle visiblity of the select flyout.

  get_addon_ownerable: -> @get('addon_ownerable')

  peer_review_users: ember.computed 'current_phase', ->
    @get('casespace_peer_review').get_peer_review_users @get('current_phase')

  peer_review_teams: ember.computed 'current_phase', ->
    @get('casespace_peer_review').get_peer_review_teams @get('current_phase')

  actions:
    toggle_select: -> @toggleProperty('select_visible') and false

    next_team:     -> @next_previous_team index_increment: +1, default: 'firstObject'
    previous_team: -> @next_previous_team index_increment: -1, default: 'lastObject'
    next_user:     -> @next_previous_user index_increment: +1, default: 'firstObject'
    previous_user: -> @next_previous_user index_increment: -1, default: 'lastObject'

    select_team: (team) -> @change_ownerable_selected(team)
    select_user: (user) -> @change_ownerable_selected(user)

  next_previous_team: (options={}) ->
    current_team = @get_addon_ownerable()
    @get('peer_review_teams').then (teams) =>
      if current_team
        index = teams.indexOf(current_team)
        if index?
          index += options.index_increment   if options.index_increment?
          team   = teams.objectAt(index)
      unless team
        team = teams.get(options.default)
      @send 'select_team', team

  next_previous_user: (options={}) ->
    current_user = @get_addon_ownerable()
    @get('peer_review_users').then (users) =>
      if current_user
        index = users.indexOf(current_user)
        if index?
          index += options.index_increment   if options.index_increment?
          user   = users.objectAt(index)
      unless user
        user = users.get(options.default)
      @send 'select_user', user

  change_ownerable_selected: (ownerable) ->
    @totem_error.throw @, "Change to ownerable is blank."  unless ownerable
    @set 'select_visible', false
    @totem_scope.view_only_on()
    @get('dock').mock_phase_states_on()
    @get('phase_manager').set_addon_ownerable_and_generate_view(ownerable)
