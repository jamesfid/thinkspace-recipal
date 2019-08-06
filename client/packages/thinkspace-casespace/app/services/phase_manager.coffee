import ember             from 'ember'
import ns                from 'totem/ns'
import totem_scope       from 'totem/scope'
import totem_messages    from 'totem-messages/messages'
import phase_manager_map from 'thinkspace-casespace/phase_manager_map'

export default ember.Object.extend

  toString: -> 'PhaseManager'

  tvo:          ember.inject.service()
  casespace:    ember.inject.service()
  totem_scope:  ember.inject.service() # also injecting as a service so can observe view only property

  # Triggered by a component to regenerate the phase view e.g. html edit.
  # Remove when html edit moved to case manager.
  regenerate_observer: ember.observer 'tvo.regenerate_view', -> @generate_view()

  is_view_only: ember.computed.reads 'totem_scope.is_view_only'  # template helper

  is_current_html: '<i class="tsi tsi-left tsi-tiny tsi-right-arrow left">'
  map:             phase_manager_map.create()

  reset_all: ->
    @set 'map', phase_manager_map.create()
    @mock_phase_states_off()
    totem_scope.ownerable_to_current_user()

  # ###
  # ### Addon Ownerable.
  # ###

  has_active_addon:           -> @get_active_addon()?
  get_active_addon:           -> @get('casespace').get_active_addon()
  get_active_addon_ownerable: -> @get('casespace').get_active_addon_ownerable()

  set_addon_ownerable_and_generate_view: (ownerable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @view_is_generated_off()
      @show_loading_outlet()
      # Using run.next to allow templates to rerender based on 'view_is_generated' turned off and
      # before generating the phase view with the new ownerable.
      ember.run.next => 
        @get('casespace').set_active_addon_ownerable(ownerable)
        @set_ownerable(ownerable).then =>
          @generate_view_with_ownerable().then =>
            @hide_loading_outlet()
            resolve()

  validate_and_set_addon_ownerable: ->
    new ember.RSVP.Promise (resolve, reject) =>
      active_addon = @get_active_addon()
      return resolve() unless active_addon
      return resolve() unless typeof(active_addon.valid_addon_ownerable) == 'function'
      ownerable = @get_active_addon_ownerable()
      active_addon.valid_addon_ownerable(ownerable).then (valid) =>
        if valid
          @set_ownerable(ownerable).then => resolve()
        else
          @get('casespace').set_active_addon_ownerable(null)
          @mock_phase_states_off()
          @set_ownerable(null).then => resolve()

  # ###
  # ### Ownerable.
  # ###

  set_ownerable: (ownerable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if ownerable
        return resolve()  if totem_scope.get_ownerable_record() == ownerable
        totem_scope.ownerable(ownerable)
        return resolve() unless @phase_is_loaded()
        @set_all_phase_states().then => resolve()
      else
        return resolve()  if totem_scope.get_ownerable_record() == totem_scope.get_current_user()
        totem_scope.ownerable_to_current_user()
        return resolve() unless @phase_is_loaded()
        @set_all_phase_states().then => resolve()

  set_ownerable_from_phase_state: (phase_state) ->
    new ember.RSVP.Promise (resolve, reject) =>
      phase_state.get('ownerable').then (ownerable) =>
        @set_ownerable(ownerable).then =>
          @get_map().set_phase_selected_phase_state(@get_phase(), phase_state)
          @get_map().set_global_selected_phase_state(phase_state)
          resolve()
      , (error) => reject(error)

  # ###
  # ###
  # ### Phase States.
  # ###
  # ###

  mock_phase_states: false
  mock_phase_states_on:  -> @set 'mock_phase_states', true
  mock_phase_states_off: -> @set 'mock_phase_states', false

  mock_phase_state_object: ember.Object.extend
    ownerable: ember.computed ->
      new ember.RSVP.Promise (resolve, reject) => resolve @get('mock_ownerable')

  get_mock_phase_state: (ownerable) ->
    @mock_phase_state_object.create
      id:             'mock'
      mock_ownerable: ownerable
      ownerable_type: totem_scope.record_type_key(ownerable)
      ownerable_id:   ownerable.get('id')

  # Phase state priority:
  #  1. phase-state-id e.g. from params query_id (null if id not found)
  #  2. selected-phase-state for ownerable and phase
  #  3. global-selected-phase-state if valid for the phase
  #  4. phase state that matches the global-selected-phase-state's ownerable
  #  5. null
  get_phase_state_for_phase: (phase, id) ->
    new ember.RSVP.Promise (resolve, reject) =>
      map = @get_map()
      if id and id != 'none'
        type = ns.to_p('phase_state')
        if phase.store.hasRecordForId(type, id)
          phase.store.find(ns.to_p('phase_state'), id).then (phase_state) => resolve(phase_state)
        else
          resolve(null)
      else
        addon_ownerable = (@has_active_addon() and @get_active_addon_ownerable()) or null
        ownerable       = addon_ownerable or totem_scope.get_current_user()
        return resolve(@get_mock_phase_state(ownerable)) if @get('mock_phase_states')
        selected        = map.find_ownerable_selected_phase_state(phase, ownerable)
        return resolve(selected)  if selected
        global_selected = map.get_global_selected_phase_state()
        if global_selected
          phase_states = map.find_ownerable_phase_states(phase, ownerable)
          return resolve(global_selected)  if phase_states.contains(global_selected)
          phase_state = map.find_phase_state_ownerable_in_phase_states(global_selected, phase_states)
          resolve(phase_state)
        else
          resolve(null)

  # Sets all of the ownerable phase states for each phase in the map.
  set_all_phase_states: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @validate_and_set_addon_ownerable().then =>
        # @debug_ownerable ">>>>>set all phase states [mock=#{@get('mock_phase_states')}]: "
        assignment = @get_assignment()
        map        = @get_map()
        if @get('mock_phase_states')
          map.set_map_without_phase_states(assignment).then => resolve()
        else
          map.set_map(assignment).then => resolve()

  # ###
  # ### Phase View Generation.
  # ###

  has_phase_view: ember.computed 'view_container', 'view_is_generated', ->
    @valid_view_container() and @get('view_is_generated')

  loaded_phase_ids:      []
  view_container:        null
  view_is_generated:     false  # true when the phase view has been generated - e.g. not a team selection view (addons uses it)
  view_is_generated_on:  -> @set 'view_is_generated', true
  view_is_generated_off: -> @set 'view_is_generated', false

  phase_is_loaded: ->
    phase = @get_phase()
    phase and @get('loaded_phase_ids').contains(phase.get 'id')

  generate_view: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @validate_and_set_addon_ownerable().then =>
        @generate_view_with_ownerable().then => resolve()

  generate_view_with_ownerable: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @view_is_generated_off()
      phase = @get_phase()
      totem_scope.authable(phase)
      if @phase_is_loaded()
        # Since it's already been loaded and approved via `validate_phase_and...` just build the view.
        # => This allows peer review to work.
        @set_totem_scope_view_ability().then =>
          @build_view(phase).then =>
            resolve()
      else
        phase_id   = phase.get('id')
        loaded_ids = @get('loaded_phase_ids')
        loaded_ids.push phase_id
        phase.store.find(ns.to_p('phase'), action: 'load', id: phase_id).then =>
          @set_all_phase_states().then =>
            @refresh_abilites_for_phase(phase).then =>
              @set_totem_scope_view_ability().then =>
                @validate_phase_and_build_view(phase).then =>
                  resolve()

  refresh_abilites_for_phase: (phase) ->
    new ember.RSVP.Promise (resolve, reject) =>
      phase.totem_data.ability.refresh().then => resolve()

  validate_phase_and_build_view: (phase) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if phase.get('can.read_phase')
        @build_view(phase).then => resolve()
      else
        @transition_from_phase(phase)
        reject()

  build_view: (phase) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @debug_ownerable()
      view_container = @get_view_container()
      view_container.removeAllChildren()
      tvo = @get('tvo')
      tvo.clear()
      tvo.hash.set_value 'show_errors', false
      tvo.hash.set_value 'process_validations', phase.get('configuration_validate')
      phase.get(ns.to_p 'phase_template').then (template) =>
        phase.get(ns.to_p 'phase_components').then (components) =>
          tvo.template.parse template.get('template')
          tvo.template.add_components(components).then =>
            view = ember.View.create template: tvo.template.compile()
            view_container.pushObject view
            @view_is_generated_on()
            @hide_loading_outlet()
            resolve()
        , (error) => reject(error)
      , (error) => reject(error)
    , (error) => reject(error)

  set_totem_scope_view_ability: ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if @get('casespace').has_active_addon()  # if addon active, the addon sets the view only value
      phase       = @get_phase()
      phase_state = @get_map().get_phase_selected_phase_state(phase)
      unless phase_state
        totem_scope.view_only_on()
        return resolve()
      if phase_state.get('is_view_only') or (phase.get('can.read_phase') and !phase.get('can.modify_phase'))
        totem_scope.view_only_on()
        return resolve()
      if phase.is_team_ownerable()
        @set_totem_scope_view_ability_team_ownerable().then => return resolve()
      else
        totem_scope.view_only_off()
        resolve()

  set_totem_scope_view_ability_team_ownerable: ->
    new ember.RSVP.Promise (resolve, reject) =>
      phase       = @get_phase()
      phase_state = @get_map().get_phase_selected_phase_state(phase)
      if phase_state
        phase_state.get('ownerable').then (ownerable) =>
          if ownerable and ownerable.get('is_member')
            totem_scope.view_only_off()
          else
            totem_scope.view_only_on()
          resolve()
      else
        totem_scope.view_only_on()
        resolve()

  transition_from_phase: (phase) ->
    app_route = totem_messages.get_app_route()
    totem_messages.error('You cannot access this phase.')
    @hide_loading_outlet()
    if phase.get('can.modify_assignment')
      app_route.transitionTo ns.to_r('assignments', 'show'), @get_assignment()
    else
      app_route.transitionTo ns.to_r('spaces', 'index')

  # ###
  # ### View Container.
  # ###

  get_current_view_container:             -> @get('view_container')
  set_current_view_container: (container) -> @set('view_container', container)

  get_view_container: ->
    if @valid_view_container()
      @get_current_view_container()
    else
      view_container = @container.lookup 'view:template_manager_view_container'
      @set_current_view_container(view_container)
      view_container

  valid_view_container: ->
    view_container = @get_current_view_container()
    view_container and not ( view_container.get('isDestroyed') or view_container.get('isDestroying') )

  # ###
  # ### Helpers.
  # ###

  get_map:        -> @get('map')
  get_assignment: -> @get('casespace').get_current_assignment()
  get_phase:      -> @get('casespace').get_current_phase()

  show_loading_outlet: -> totem_messages.show_loading_outlet()
  hide_loading_outlet: -> totem_messages.hide_loading_outlet()

  debug_ownerable: (text='') ->
    ownerable = totem_scope.get_ownerable_record()
    unless ownerable
      console.warn text + 'ownerable is blank'
      return
    if ownerable and totem_scope.ownerable_is_type_user()
      console.info "#{text}[user: #{ownerable.get('first_name')}] ownerable:", ownerable.toString()
    else
      console.info "#{text}[team: #{ownerable.get('title')}] ownerable:", ownerable.toString()

  debug_phase_states: ->
    map        = @get_map()
    assignment = @get_assignment()
    ownerable  = totem_scope.get_ownerable_record()
    console.warn '-------------------------------------------------'
    console.info 'ownerable:', ownerable
    console.info 'assignment:', assignment
    assignment.get(ns.to_p 'phases').then (phases) =>
      phases.forEach (phase) =>
        console.info '......phase:', phase
        console.warn 'phase_state:', phase.get('phase_state')
      console.warn '-------------------------------------------------'
