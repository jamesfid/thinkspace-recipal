import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base  from 'thinkspace-casespace-case-manager/components/wizards/base'

export default base.extend
  # Wizard properties
  step:         null
  steps:        ['details', 'templates', 'phases', 'logistics', 'confirmation']

  # Assignment properties
  model:      null # The assignment
  assignment: ember.computed.alias 'model'

  title:        null
  instructions: null
  due_at:       null
  model_state:  null
  release_at:   null
  template:     null

  build_mode: ember.computed 'is_editing', -> if @get('is_editing') then 'edit' else 'create'


  # Components
  c_wizard_step: ember.computed 'step', ->
    step = @get('step')
    step = @get('default_step') unless ember.isPresent(step)
    ns.to_p 'case_manager', 'assignment', 'wizards', 'casespace', 'steps', step

  # Query param management
  check_bundle_type: (bundle_type, options={}) -> new ember.RSVP.Promise (resolve, reject) => resolve()
  check_step: (step, options={}) -> 
    new ember.RSVP.Promise (resolve, reject) =>
      direction  = options.direction
      is_editing = @get('is_editing')
      switch is_editing
        when true
          step = 'phases'  if ember.isEqual(step, 'templates') and ember.isEqual(direction, 'forward')
          step = 'details' if ember.isEqual(step, 'templates') and ember.isEqual(direction, 'back')
      resolve(step)

  # Completion callbacks
  complete_details: ->  new ember.RSVP.Promise (resolve, reject) => resolve()

  complete_templates: ->
    new ember.RSVP.Promise (resolve, reject) =>
      assignment = @get('model')
      title      = @get('title')
      template   = @get('template')
      space_id   = @get('space_id')

      assignment.set('title', title)
      assignment.set('builder_template_id', template.get('id'))
      assignment.set('bundle_type', 'casespace')
      assignment.set('builder_version', 1)

      assignment.store.find(ns.to_p('space'), space_id).then (space) =>
        assignment.set('space', space)
        @totem_messages.show_loading_outlet message: 'Creating case...'
        assignment.save().then =>
          @get('wizard_manager').transition_to_assignment_edit assignment, queryParams: { step: 'phases' }
          @totem_messages.hide_loading_outlet()
          resolve(true) # Return, do not let complete_step take over since we are transitioning here.
        , (error) => reject(error)
      , (error) => reject(error)

  complete_phases:  ->  new ember.RSVP.Promise (resolve, reject) => resolve()

  complete_logistics: ->
    new ember.RSVP.Promise (resolve, reject) =>
      assignment   = @get('model')
      instructions = @get('instructions')
      release_at   = @get('release_at')
      due_at       = @get('due_at')
      state        = @get('model_state')

      assignment.set('instructions', instructions)
      assignment.set('release_at', release_at)
      assignment.set('due_at', due_at)
      assignment.set('state', state)
      resolve()

  complete_confirmation: ->
    new ember.RSVP.Promise (resolve, reject) =>
      assignment = @get('model')
      assignment.save().then (assignment) =>
        console.log "[casespace wizard] Assignment saved: ", assignment
        @get('thinkspace').disable_wizard_mode()
        @get('wizard_manager').transition_to_assignment_show(assignment)
      , (error) => reject(error)

  actions:
    set_title:        (title) -> @set 'title', title
    set_step:         (step) ->  @set 'step', step
    set_template:     (template) -> @set 'template', template
    set_instructions: (instructions) ->  @set 'instructions', instructions
    set_due_at:       (due_at) -> @set 'due_at', due_at
    set_release_at:   (release_at) -> @set 'release_at', release_at
    set_model_state:  (state) -> @set 'model_state', state # https://github.com/emberjs/ember.js/issues/4764
 