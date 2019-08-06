import ember from 'ember'
import ns    from 'totem/ns'
import ajax from 'totem/ajax'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'

export default base.extend auth_mixin,
  phase_manager: ember.inject.service()
  casespace:     ember.inject.service()
  tvo:           ember.inject.service()

  titleToken: (model) -> model.get('title')

  deactivate: ->
    @_super()
    controller = @get 'controller'
    controller.reset_phase_settings()
    controller.reset_query_id() # query_id persists between cases, need to reset.

  model: (params) ->
    @store.find(ns.to_p('phase'), params.phase_id).then (phase) =>
      @totem_messages.api_success source: @, model: phase
    , (error) =>
      @totem_messages.api_failure error, source: @, model: ns.to_p('phase')

  afterModel: (phase, transition) ->
    transition.abort() unless phase
    @totem_messages.hide_loading_outlet() if ember.isEqual(@get('casespace.current_phase'), phase) # Hide outlet if navigating to same phase.
    @get('casespace').set_current_models(phase: phase).then =>
      @get('phase_manager').set_all_phase_states().then =>
        @validate_phase_state(phase)

  renderTemplate: (controller, phase) -> @route_based_on_phase_state(phase)

  # ###
  # ### Helper functions.
  # ###

  get_casespace:         -> @get 'casespace'
  get_assignment:        -> @get_casespace().get_current_assignment()
  get_phase:             -> @get_casespace().get_current_phase()
  get_phase_manager:     -> @get 'phase_manager'
  get_phase_manager_map: -> @get 'phase_manager.map'
  show_loading_outlet:   -> @get_phase_manager().show_loading_outlet()
  hide_loading_outlet:   -> @get_phase_manager().hide_loading_outlet()

  # ###
  # ### Route on Phase State.
  # ###
  validate_phase_state: (phase) ->
    assignment = @get_assignment()
    assignment.totem_data.ability.refresh().then =>
      current_user = @totem_scope.get_current_user()
      assignment.totem_data.ability.for_ownerable(current_user).then (abilities) =>
        can_update = abilities.can.update
        # Get the phase state 'current_state' via the phase manager.
        # Fix: 423 when going from a user based phase to a 'locked' team based phase.
        #      At this point the ownerable is still the user, therefore doing a phase.get('is_locked')
        #      will return undefined (since trying to get a phase state for the user not their team).
        query_id = @get('controller.query_id')
        @get_phase_manager().get_phase_state_for_phase(phase, query_id).then (phase_state) =>
          can_view   = if phase_state then (not phase_state.get('is_locked')) else false
          can_access = can_view or can_update
          # If the phase state is locked, redirect back to 'assignments#show' unless
          # can update the phase (e.g. gradebook)
          unless can_access
            @totem_messages.error('You cannot access a locked phase.')
            @transition_to_assignment() 

  route_based_on_phase_state: (phase) ->
    can_update    = @get_assignment().get('can_update')
    phase_manager = @get_phase_manager()
    map           = @get_phase_manager_map()
    query_id      = @get('controller.query_id')
    phase_manager.get_phase_state_for_phase(phase, query_id).then (phase_state) =>
      switch
        when phase_state
          phase_manager.set_ownerable_from_phase_state(phase_state).then => @render_view()

        when map.ownerable_has_multiple_phase_states(phase)
          if can_update and phase_manager.has_active_addon()
            @render_view()
          else
            @render ns.to_p('phases', 'select_phase_state')  # note: this is NOT in the template/components folder e.g. ns.to_p not ns.to_t
            @hide_loading_outlet()

        when can_update
          @render_view()

        else
          @transition_to_assignment()

  transition_to_assignment: ->
    @hide_loading_outlet()
    @transitionTo ns.to_r('assignments', 'show'), @get_assignment()

  render_view: ->
    @show_loading_outlet()
    @get_phase_manager().generate_view_with_ownerable().then =>
      @render()
      @hide_loading_outlet()

  get_ownerable: -> @totem_scope.get_ownerable_record()

  # ###
  # ### Actions.
  # ###

  actions:
    select_phase_state: (phase_state) -> @get_phase_manager().set_ownerable_from_phase_state(phase_state).then => @render_view()

    submit: ->
      tvo = @get('tvo')
      tvo.status.all_valid().then (status) =>
        @submit_phase()
      , (status) =>
        tvo.hash.set_value('show_errors', true)
        tvo.hash.set_value('phase_submit_messages_title', 'Please correct the following:')
        tvo.hash.set_value('phase_submit_messages', status.status_messages)

  submit_phase: ->
    phase = @get_phase()
    query = 
      verb:   'put'
      action: 'submit'
      id:     phase.get('id')
      model:  phase
    # A store.find on a phase with an action does not side load data in time and introduces a race condition.
    # => This resolves the issue (doing a pushPayload on the model needed later in the chains).
    ajax.object(query).then (payload) =>
      phase.store.pushPayload(ns.to_p('phase_state'), payload)
      @totem_messages.api_success source: @, model: phase, i18n_path: ns.to_o 'phase', 'submit'
      @transition_after_submit()
    , (error) =>
      @totem_messages.api_failure error, source: @, model: phase

  # TODO: When submit a team based phase (or vice-versa), the 'is_unlocked'
  # represents the phase state of the current ownerable.  If subsequent phases
  # are a different ownerable, they will not have a current ownerable phase state
  # will transition to the assignment#show.
  # 1. Should this be based on phase state?  e.g. multiple teams for a phase, go to the
  #    next team for the phase rather than the next phase.
  # 2. Change to check for phase.team_ownerable and switch ownerables.
  transition_after_submit: ->
    assignment = @get_assignment()
    phase      = @get_phase()
    assignment.get(ns.to_p('phases')).then =>  # ensure all the assignment's are phases loaded
      phases = assignment.get('phases')  # phases association sorted by position
      index  = phases.indexOf(phase)
      if index?
        next_phase = phases.slice(index + 1).filterBy('is_unlocked').get('firstObject')
        if next_phase
          phase_state = @get_phase_manager_map().find_ownerable_selected_phase_state(next_phase, @get_ownerable())
          if ember.isPresent(phase_state)
            @transitionTo ns.to_r('phases', 'show'), assignment, next_phase, queryParams: { query_id: phase_state.get('id') }
          else
            @transitionTo ns.to_r('phases', 'show'), assignment, next_phase, queryParams: { query_id: 'none' }
          return
      @totem_messages.info 'Case submitted successfully.'
      @transition_to_assignment()

