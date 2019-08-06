import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  phase_manager:       ember.inject.service()
  casespace_gradebook: ember.inject.service()
  casespace:           ember.inject.service()

  current_space:      ember.computed.reads 'casespace.current_space'
  current_assignment: ember.computed.reads 'casespace.current_assignment'
  current_phase:      ember.computed.reads 'casespace.current_phase'
  addon_ownerable:    ember.computed.reads 'casespace.active_addon_ownerable'

  c_phase_score: ns.to_p 'gradebook', 'phase/score'
  c_phase_state: ns.to_p 'gradebook', 'phase/state'
  c_overview:    ns.to_p 'gradebook', 'phase/overview'

  t_header:      ns.to_t 'gradebook', 'phase/header'
  t_footer:      ns.to_t 'gradebook', 'phase/footer'
  t_overview:    ns.to_t 'gradebook', 'phase/overview'
  t_team_select: ns.to_t 'gradebook', 'phase/team_select'
  t_user_select: ns.to_t 'gradebook', 'phase/user_select'

  select_user_prompt:    'Select a Student'
  select_team_prompt:    'Select a Team'

  select_visible: false # used to toggle visiblity of the select flyout.

  get_addon_ownerable:     -> @get('addon_ownerable')
  get_casespace_gradebook: -> @get('casespace_gradebook')

  # ###
  # ### Gradebook Users - all space users.
  # ###

  gradebook_users: ember.computed ->
    space      = @get('current_space')
    assignment = @get('current_assignment')
    @get_casespace_gradebook().get_gradebook_users(space, assignment)

  # ###
  # ### Gradebook Teams - all phase teams for an assignment.
  # ###

  gradebook_phase_teams: ember.computed 'current_phase', ->
    assignment = @get('current_assignment')
    phase      = @get('current_phase')
    @get_casespace_gradebook().get_gradebook_phase_teams(assignment, phase)

  # ###
  # ### Ownerable Total Score.
  # ###

  phase_score_change: null  # property that triggers an update of phase score
  notify_phase_score_change: -> @notifyPropertyChange 'phase_score_change'

  total_score: ember.computed 'phase_score_change', 'current_phase', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      map                = @get('phase_manager.map')
      current_assignment = @get 'current_assignment'
      return resolve(0) unless current_assignment
      current_assignment.get(ns.to_p 'phases').then (phases) =>
        return resolve(0) unless phases
        total = 0
        phases.forEach (phase) =>
          phase_states = map.get_ownerable_phase_states(phase)
          phase_states.forEach (phase_state) =>
            total += phase_state.get('score') or 0
        resolve(total)
    ds.PromiseObject.create promise: promise

  # ###
  # ### Actions.
  # ###

  actions:
    toggle_select: ->
      @toggleProperty 'select_visible'
      return

    next_team:     -> @next_previous_team index_increment: +1, default: 'firstObject'
    previous_team: -> @next_previous_team index_increment: -1, default: 'lastObject'
    next_user:     -> @next_previous_user index_increment: +1, default: 'firstObject'
    previous_user: -> @next_previous_user index_increment: -1, default: 'lastObject'

    select_team: (team) -> @change_ownerable_selected(team)
    select_user: (user) -> @change_ownerable_selected(user)

    score_view:  (view)  -> @set 'current_score_view', view

    phase_score: (score) -> @save_phase_score(score)
    phase_state: (state) -> @save_phase_state(state)

  next_previous_team: (options={}) ->
    current_team = @get_addon_ownerable()
    @get('gradebook_phase_teams').then (teams) =>
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
    @get('gradebook_users').then (users) =>
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
    @get('phase_manager').set_addon_ownerable_and_generate_view(ownerable)

  # ###
  # ### Save Score.
  # ###

  save_phase_score: (score) ->
    phase       = @get('current_phase')
    phase_state = phase.get('phase_state')
    phase_state.get(ns.to_p 'phase_score').then (phase_score) =>
      unless phase_score
        phase_score = phase.store.createRecord ns.to_p('phase_score')
        phase_score.set ns.to_p('phase_state'), phase_state
      score = Number(score)  # score is text but the model attribute is a Number; convert to a number for isDirty check
      phase_score.set 'score', score
      if phase_score.get('isDirty')
        phase_score.save().then (record) =>
          @totem_messages.api_success source: @, model: record, action: 'save', i18n_path: ns.to_o('phase_score', 'save')
          @focus_on_score_input()
          @notify_phase_score_change()
        , (error) =>
          @totem_messages.api_failure error, source: @, model: phase_score

  # ###
  # ### Save State.
  # ###

  save_phase_state: (state) ->
    phase       = @get('current_phase')
    phase_state = phase.get('phase_state')
    unless phase_state.get('current_state') == state
      phase_state.set 'new_state', state
      phase_state.save().then (record) =>
        @totem_messages.api_success source: @, model: record, action: 'save', i18n_path: ns.to_o('phase_state', 'save')
        @focus_on_score_input()
      , (error) =>
        @totem_messages.api_failure error, source: @, model: phase_state

  # ###
  # ### Input text field HTML attributes.
  # ###

  # The score's input textfield's html attributes. e.g. {readonly: true, disabled: true}
  # Currently not populated with any configuration settings since readonly and disabled
  # are set via: totem_scope.view_only_on().
  view_attrs: ember.computed 'current_phase', -> {}

  focus_on_score_input: ->
    $input = @$(':input').first()
    $input.focus()