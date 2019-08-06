import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-builder/components/wizard/steps/base'

export default base.extend
  # ### Properties
  component_map: null
  edit_mode:     'content'

  transition_previous_phase: null
  transition_next_phase:     null

  # ### Computed properties
  is_edit_mode_content:  ember.computed.equal 'edit_mode', 'content'
  is_edit_mode_settings: ember.computed.equal 'edit_mode', 'settings'

  has_previous_phase: ember.computed.notEmpty 'transition_previous_phase'
  has_next_phase:     ember.computed.notEmpty 'transition_next_phase'

  # ### Services
  tvo: ember.inject.service()

  # ### Routes
  r_cases_phases: ns.to_r 'builder', 'cases', 'phases'
  r_phases_show:  ns.to_r 'casespace', 'phases', 'show'

  # ### Components
  c_phases_edit_layout:   ns.to_p 'builder', 'phases', 'edit', 'layout'
  c_phases_edit_settings: ns.to_p 'builder', 'phases', 'edit', 'settings'

  # ### Observers

  # Used to support transitioning to other phase edits (since this component does not reset since it is the same route)
  model_observer: ember.observer 'model', ->
    @reset_all_data_loaded()
    @set_all()

  # ### Events
  init: ->
    @_super()
    @set_all()

  # ### Initialization promises
  set_all: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @set_assignment().then => @load_phase().then => @set_phase_components().then => 
        @set_phase_template().then => @set_transition_phases().then =>
          @set_all_data_loaded()
          resolve()

  set_transition_phases: ->
    new ember.RSVP.Promise (resolve, reject) =>
      assignment = @get 'assignment'
      model      = @get 'model'

      assignment.get('active_phases').then (phases) =>
        index = phases.indexOf model
        return resolve() unless ember.isPresent(index)
        prev_phase = phases[index - 1]
        next_phase = phases[index + 1]
        @set 'transition_previous_phase', prev_phase
        @set 'transition_next_phase', next_phase
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  set_assignment: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      model.get(ns.to_p('assignment')).then (assignment) =>
        id = assignment.get 'id'
        @tc.query(ns.to_p('assignment'), {id: id, action: 'load'}, single: true).then (assignment) =>
          @set 'assignment', assignment
          resolve()
        , (error) => @error(error)
      , (error) => @error(error)
    , (error) => @error(error)

  load_phase: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      id    = model.get 'id'
      @tc.query(ns.to_p('phase'), {id: id, action: 'load'}).then =>
        resolve()
      , (error) => @error(error)

  set_phase_components: -> 
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      model.get(ns.to_p('phase_components')).then (phase_components) =>
        @set 'phase_components', phase_components
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  set_phase_template: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      model.get(ns.to_p('phase_template')).then (phase_template) =>
        @set 'phase_template', phase_template
        @create_phase_component_map().then =>
          @parse_phase_template(phase_template)
          resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  # ### Template parsing
  create_phase_component_map: ->
    new ember.RSVP.Promise (resolve, reject) =>
      component_map    = @set_component_map()
      phase_components = @get 'phase_components'
      promises         = []

      phase_components.forEach (phase_component) =>
        promise = new ember.RSVP.Promise (resolve, reject) =>
          phase_component.get('component').then (component) =>
            phase_component.get('componentable').then (componentable) =>
              component_map.set phase_component, {phase_component: phase_component, component: component, componentable: componentable}
              resolve()
          , (error) => @error(error)
        promises.pushObject(promise)

      ember.RSVP.all(promises).then =>
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  set_component_map: ->
    component_map = ember.Map.create()
    @set 'component_map', component_map
    component_map

  parse_phase_template: (pt) ->
    phase_components = @get 'phase_components'
    component_map    = @get 'component_map'

    tvo = @get 'tvo'
    tvo.clear()
    tvo.template.parse pt.get 'template'
    $template        = tvo.template.get_template()
    $components      = $template.find('component')

    for component in $components
      $component = $(component)
      section    = $component.attr('section')
      if ember.isPresent(section)
        phase_component = phase_components.findBy 'section', section
        values          = component_map.get phase_component
        c_componentable = ns.to_p 'builder', 'phases', 'edit', 'componentable'
        value_path      = tvo.value.set_value values
        html            = "{{ component '#{c_componentable}' model=tvo.#{value_path}.componentable component=tvo.#{value_path}.component phase_component=tvo.#{value_path}.phase_component }}"
        $component.replaceWith(html)

    tvo.template.set '$template', $template
    template = tvo.template.compile()
    @set 'template', template

  actions:
    set_edit_mode_settings: ->
      @totem_data.ability.unload()
      @set 'edit_mode', 'settings'

    set_edit_mode_content:  -> @set 'edit_mode', 'content'

    next_phase: ->
      phase = @get 'transition_next_phase'
      return unless ember.isPresent(phase)
      @get('builder').transition_to_phases_edit(phase)

    previous_phase: ->
      phase = @get 'transition_previous_phase'
      return unless ember.isPresent(phase)
      @get('builder').transition_to_phases_edit(phase)