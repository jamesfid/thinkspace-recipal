import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import base  from 'thinkspace-casespace/components/ownerable/bar/base'

export default base.extend
  # ### Services
  casespace_gradebook: ember.inject.service()
  
  # ### Properties
  is_team_collaboration: false
  is_gradebook:          true

  is_scoring:             false
  is_viewing_total_score: false
  is_viewing_phase_state: false

  phase_state: null
  children:    null

  # ### Computed properties
  ownerables: ember.computed 'model', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      is_team_collaboration = @get_is_team_collaboration()
      casespace             = @get('casespace')
      gradebook             = @get('casespace_gradebook')
      if is_team_collaboration
        phase      = @get 'model'
        assignment = casespace.get_current_assignment()
        gradebook.get_gradebook_phase_teams(assignment, phase).then (teams) =>
          resolve(teams)
      else
        space      = casespace.get_current_space()
        assignment = casespace.get_current_assignment()
        gradebook.get_gradebook_users(space, assignment).then (users) =>
          resolve(users)
    ta.PromiseArray.create promise: promise


  # ### Components
  c_phase_score:    ns.to_p 'casespace', 'ownerable', 'bar', 'gradebook', 'phase', 'score'
  c_phase_state:    ns.to_p 'casespace', 'ownerable', 'bar', 'gradebook', 'phase', 'state'
  c_phase_overview: ns.to_p 'casespace', 'ownerable', 'bar', 'gradebook', 'phase', 'overview'

  # ### Observers

  # Make sure when the phase changes the appropriate components are updated.
  current_phase_observer: ember.observer 'casespace.current_phase', -> 
    ember.run.schedule 'afterRender', =>
      @callback_set_addon_ownerable()

  # ### Events
  init: ->
    @_super()
    @set 'children', new Array

  # ### Callbacks
  callback_set_addon_ownerable: ->
    phase       = @get 'current_phase'
    phase_state = phase.get 'phase_state'
    @set 'phase_state', phase_state
    @notify_phase_score_change()

    children = @get 'children'
    children.forEach (child) => child.callback_set_addon_ownerable()

  register_child: (component) ->
    children = @get 'children'
    children.pushObject component

  # ### Ownerable Total Score.
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
    ta.PromiseObject.create promise: promise

  # ### Save score
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
          #@focus_on_score_input()
          @notify_phase_score_change()
        , (error) =>
          @totem_messages.api_failure error, source: @, model: phase_score

  # ### Save state
  save_phase_state: (state) ->
    phase       = @get('current_phase')
    phase_state = phase.get('phase_state')
    unless phase_state.get('current_state') == state
      phase_state.set 'new_state', state
      phase_state.save().then (record) =>
        @totem_messages.api_success source: @, model: record, action: 'save', i18n_path: ns.to_o('phase_state', 'save')
        #@focus_on_score_input()
      , (error) =>
        @totem_messages.api_failure error, source: @, model: phase_state

  # ### Scoring helpers
  set_is_scoring:    -> @set 'is_scoring', true
  reset_is_scoring:  -> @set 'is_scoring', false
  toggle_is_scoring: -> @toggleProperty 'is_scoring'

  actions:
    toggle_scorecard: -> @toggle_is_scoring()
    phase_score: (score) -> @save_phase_score(score)
    phase_state: (state) -> @save_phase_state(state)
    toggle_is_viewing_phase_state: -> @toggleProperty 'is_viewing_phase_state'
    toggle_is_viewing_total_score: -> @toggleProperty 'is_viewing_total_score'

    delete_ownerable_data: ->
      ownerable = @get 'addon_ownerable'
      phase     = @get 'current_phase'
      confirm   = window.confirm "Are you sure you want to clear #{ownerable.get('first_name')}'s data for #{phase.get('title')}?  This will remove all of their responses for this phase.  This process is NOT REVERSIBLE.  This will refresh your browser."
      if confirm
        query = 
          id:             phase.get('id')
          ownerable_id:   ownerable.get('id')
          ownerable_type: @totem_scope.standard_record_path(ownerable)
          action:         'delete_ownerable_data'
          verb:           'PUT'
        @totem_messages.show_loading_outlet(message: 'Removing learner data...')
        @tc.query(ns.to_p('phase'), query, single: true).then =>
          @set_addon_ownerable(ownerable).then =>
            @totem_messages.hide_loading_outlet()
            location.reload() # TODO: Temporary until we figure out how to handle this in Ember.