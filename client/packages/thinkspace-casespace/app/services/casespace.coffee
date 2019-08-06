import ember      from 'ember'
import ns         from 'totem/ns'

export default ember.Object.extend
  # ### Services
  thinkspace: ember.inject.service()

  # ### Properties
  phase_settings: null

  # ### Helpers
  reset_all: ->
    @reset_models()
    @reset_active_addon()

  reset_models: ->
    @set_current_space(null)
    @set_current_assignment(null)
    @set_current_phase(null)

  reset_active_addon: ->
    @set_active_addon_ownerable(null)
    @set_active_addon(null)

  # ### Phases show controller (for phase settings)
  # Phase settings are set via query param `phase_settings` on the casespace/phases/show controller.
  # => They're initially set via an observer and all changes are proxied to this service.
  # => The proxy is in place for components to easily inject and bind to phase settings changes here.
  get_phase_settings: -> @get 'phase_settings'
  set_phase_settings: (phase_settings) -> @set 'phase_settings', phase_settings

  get_phases_show_controller: -> @container.lookup('controller:thinkspace/casespace/phases/show')
  set_phase_settings_query_params: (phase_settings) ->
    controller = @get_phases_show_controller()
    controller.set_phase_settings phase_settings

  # ###
  # ### Current Models.
  # ###

  current_space:      null
  current_assignment: null
  current_phase:      null

  current_model: ember.computed 'current_space', 'current_assignment', 'current_phase', ->
    @get('current_phase') or @get('current_assignment') or @get('current_space') or null

  get_current_space:      -> @get 'current_space'
  get_current_assignment: -> @get 'current_assignment'
  get_current_phase:      -> @get 'current_phase'

  set_current_space:      (space)      -> @set 'current_space', space
  set_current_assignment: (assignment) -> @set 'current_assignment', assignment
  set_current_phase:      (phase)      -> @set 'current_phase', phase

  set_current_models: (current_models={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      switch
        when phase = current_models.phase
          phase.get(ns.to_p 'assignment').then (assignment) =>
            assignment.get(ns.to_p 'space').then (space) =>
              @set_current_space(space)            unless @get_current_space() == space
              @set_current_assignment(assignment)  unless @get_current_assignment() == assignment
              @set_current_phase(phase)
              resolve()
            , (error) => reject(error)
          , (error) => reject(error)
        when assignment = current_models.assignment
          assignment.get(ns.to_p 'space').then (space) =>
            @set_current_phase(null)
            @set_current_space(space) unless @get_current_space() == space
            @set_current_assignment(assignment)
            resolve()
          , (error) => reject(error)
        when space = current_models.space
          @set_current_assignment(null)
          @set_current_phase(null)
          @set_current_space(space) unless @get_current_space() == space
          resolve()
        else
          @reset_all()
          resolve()

  # ###
  # ### Addons.
  # ###

  active_addon:           null
  active_addon_ownerable: null

  has_sticky_addon: ember.computed 'active_addon', ->
    addon = @get_active_addon()
    return false unless addon
    name = addon.get('addon_name')
    name == 'gradebook' or name == 'peer_review'

  has_active_addon: -> @get('active_addon')?
  get_active_addon: -> @get 'active_addon'

  # The current active addon's function 'exit_addon' will be called before setting a new addon.
  # The target function typically would clear any persistent data (e.g. in a service).
  set_active_addon: (addon=null) ->
    active_addon = @get('active_addon')
    @debug_active_addon(addon, active_addon)
    active_addon.exit_addon()  if active_addon and typeof(active_addon.exit_addon) == 'function'
    @set 'active_addon', addon

  get_active_addon_ownerable:             -> @get 'active_addon_ownerable'
  set_active_addon_ownerable: (ownerable) -> @set 'active_addon_ownerable', ownerable

  debug_active_addon: (addon, active_addon) ->
    console.info 'exit...active addon:', active_addon.toString()  if active_addon
    console.info 'set....active addon:', addon.toString()  if addon
    console.info 'clear..active addon'  unless addon
    ownerable = @get_active_addon_ownerable()
    console.info 'current active addon ownerable:', ownerable.toString()  if ownerable

  dock_is_visible: ember.computed.or 'current_assignment', 'current_phase'

  # ### Sidepocket
  c_sidepocket_component: false
  sidepocket_is_expanded: false
  sidepocket_width:       1

  sidepocket_width_class: ember.computed 'sidepocket_is_expanded', 'sidepocket_width', -> 
    return null unless @get 'sidepocket_is_expanded'
    "sidepocket_width-#{@get('sidepocket_width')}"

  hide_sidepocket:   -> 
    @set 'sidepocket_is_expanded', false
    @reset_sidepocket_width()
  show_sidepocket:   -> @set 'sidepocket_is_expanded', true
  toggle_sidepocket: -> @toggleProperty 'sidepocket_is_expanded'

  set_sidepocket_width:   (width) -> @set 'sidepocket_width', width
  reset_sidepocket_width: -> @set 'sidepocket_width', 1

  set_active_sidepocket_component: (path) -> 
    @set 'c_sidepocket_component', path
    @show_sidepocket()

  reset_active_sidepocket_component: ->
    @hide_sidepocket()
    # Will error about rendering component `null` if not in a run next.
    ember.run.next =>
      @set 'c_sidepocket_component', null
    
  # ### Transitions
  transition_to_current_assignment: ->
    assignment = @get 'current_assignment'
    return unless ember.isPresent(assignment)
    thinkspace = @get 'thinkspace'
    transition = thinkspace.get_current_transition()
    return unless ember.isPresent(transition)
    router     = transition.router
    router.transitionTo ns.to_r('assignments', 'show'), assignment

  transition_to_phase: (phase) ->
    return unless ember.isPresent(phase)
    @set_current_models(phase: phase).then =>
      assignment = @get_current_assignment()
      return unless ember.isPresent(assignment)
      thinkspace = @get 'thinkspace'
      transition = thinkspace.get_current_transition()
      console.warn 'transition:', transition
      return unless ember.isPresent(transition)
      router = transition.router
      router.transitionTo ns.to_r('phases', 'show'), assignment, phase
