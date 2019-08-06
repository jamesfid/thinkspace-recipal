import ember             from 'ember'
import ns                from 'totem/ns'
import util              from 'totem/util'
import tc                from 'totem/cache'
import totem_messages    from 'totem-messages/messages'
import totem_scope       from 'totem/scope'

# Steps
import step_details   from 'thinkspace-builder/steps/details'
import step_templates from 'thinkspace-builder/steps/templates'
import step_phases    from 'thinkspace-builder/steps/phases'
import step_logistics from 'thinkspace-builder/steps/logistics'
import step_overview  from 'thinkspace-builder/steps/overview'

export default ember.Service.extend
  # ### Properties
  model:          null
  steps:          null

  components_map: null
  values:         null

  is_saving:              false
  toolbar_action_handler: null # Where the toolbar sends actions to.

  # ### Computed Properties
  has_toolbar: false

  # ### Components
  c_step:                    ember.computed 'step', -> @get('step.component_path')
  c_builder_toolbar:         null

  # ### Events
  reset: (route=null) ->
    console.warn "[builder] Resetting...", @
    @initialize_values()
    @initialize_maps()
    @initialize_steps()
    @set 'route', route if ember.isPresent(route)

  # ### Maps
  initialize_maps: ->
    @set 'components_map', ember.Map.create()

  get_components_map: -> @get 'components_map'

  # ### Values
  initialize_values: -> @set 'values', ember.Object.create()
  set_value:         (property, value) ->  @set "values.#{property}", value
  get_value:         (property) -> @get "values.#{property}"

  # ### Step helpers
  initialize_steps: -> 
    @set 'steps', [
      step_details.create(container: @container),
      step_templates.create(container: @container),
      step_phases.create(container: @container),
      step_logistics.create(container: @container),
      step_overview.create(container: @container)
    ]

  register_step_component: (component) ->
    step = @get 'step'
    @get_components_map().set step, component

  set_current_step_from_id: (id) ->
    steps = @get 'steps'
    step  = steps.findBy 'id', id
    console.warn "[builder] Could not find step for id: [#{id}]" unless ember.isPresent(step)
    @set 'step', step

  set_current_step:                (step) -> @set_current_step_from_id step.id
  set_current_step_and_transition: (step) ->
    @set_current_step step
    @transition_to_step step

  # ### Model helpers
  get_space: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model      = @get 'model'
      model_type = totem_scope.standard_record_path(model)

      switch model_type
        when ns.to_p('assignment')
          model.get(ns.to_p('space')).then (space) =>
            resolve(space)
          , (error) => @error(error)
        when ns.to_p('phase')
          model.get(ns.to_p('assignment')).then (assignment) =>
            assignment.get(ns.to_p('space')).then (space) =>
              resolve(space)
            , (error) => @error(error)
          , (error) => @error(error)

  get_assignment: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model      = @get 'model'
      model_type = totem_scope.standard_record_path(model)

      switch model_type
        when ns.to_p('assignment')
          resolve(model)
        when ns.to_p('phase')
          model.get(ns.to_p('assignment')).then (assignment) =>
            resolve(assignment)
          , (error) => @error(error)

  # ### Roster helpers
  get_roster: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_space().then (space) =>
        query = 
          id:     space.get 'id'
          action: 'roster'
        tc.query(ns.to_p('space'), query, payload_type: ns.to_p('user')).then (users) =>
          resolve(users)
        , (error) => @error(error)
      , (error) => @error(error)
    , (error) => @error(error)

  # ### Misc. helpers
  warn: (message) -> console.warn message

  # ### Saving helpers
  set_is_saving:   -> 
    @set 'is_saving', true
    totem_messages.show_loading_outlet()
    
  reset_is_saving: -> 
    @set 'is_saving', false
    totem_messages.hide_loading_outlet()

  # ### Transition helpers
  transition_to_next_step: ->
    next_step = @get_step_from_offset(1)
    @warn "[builder] Cannot transition without a valid next step." unless ember.isPresent(next_step)
    @warn "[builder' Cannot transition without a route_path defined on the step [#{step.id}]" unless next_step.route_path?
    @transition_to_step(next_step)

  transition_to_previous_step: ->
    prev_step = @get_step_from_offset(-1)
    @warn "[builder] Cannot transition without a valid next step." unless ember.isPresent(prev_step)
    @warn "[builder' Cannot transition without a route_path defined on the step [#{step.id}]" unless prev_step.route_path?
    @transition_to_step(prev_step)

  transition_to_step: (step) ->
    route = @get 'route'
    model = @get 'model'
    @warn "[builder] Cannot transition without a valid route set." unless ember.isPresent(route)
    @warn "[builder] Cannot transition without a valid model." unless ember.isPresent(model)
    model_type = totem_scope.standard_record_path(model)

    switch model_type
      when ns.to_p('assignment')
        route.transitionTo step.route_path, model
      when ns.to_p('phase')
        model.get(ns.to_p('assignment')).then (assignment) =>
          route.transitionTo step.route_path, assignment

  transition_to_assignment: ->
    route = @get 'route'
    @warn "[builder] Cannot transition without a valid route set." unless ember.isPresent(route)
    @get_assignment().then (assignment) =>
      route.transitionTo ns.to_r('casespace', 'assignments', 'show'), assignment

  transition_to_phases_edit: (phase) ->
    route = @get 'route'
    @warn "[builder] Cannot transition without a valid route set." unless ember.isPresent(route)
    route.transitionTo ns.to_r('builder', 'phases', 'edit'), phase

  get_step_from_offset: (offset) ->
    step     = @get 'step'
    steps    = @get 'steps'
    index    = steps.indexOf(step)
    new_step = steps.objectAt(index + offset)
    new_step

  # ### Model helpers
  set_model: (model) -> 
    @set 'model', model
    @reset_toolbar() # Needed to reset the toolbar when the route changes.

  get_model: -> @get 'model'

  # ### Toolbar helpers
  set_toolbar: (action_handler, path) ->
    ember.run.next =>
      @set 'c_builder_toolbar', path
      @set 'toolbar_action_handler', action_handler
      @set 'has_toolbar', true

  reset_toolbar: ->
    @set 'has_toolbar', false
    ember.run.next =>
      @set 'toolbar_action_handler', null
      @set 'c_builder_toolbar', null