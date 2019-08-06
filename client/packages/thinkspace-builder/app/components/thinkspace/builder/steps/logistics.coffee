import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-builder/components/wizard/steps/base'
import cke   from 'totem/mixins/ckeditor'

export default base.extend cke,

  registered_phases: ember.makeArray()

  # ### Services
  ttz: ember.inject.service()

  # ### Computed properties
  instructions: ember.computed.reads 'builder.model.instructions'
  release_at:   ember.computed.reads 'builder.model.release_at'
  due_at:       ember.computed.reads 'builder.model.due_at'

  friendly_release_at: ember.computed 'release_at', ->
    date = @get 'release_at'
    return 'N/A' unless ember.isPresent(date)
    @get('ttz').format date, format: 'MMMM Do YYYY, h:mm z', zone: @get('ttz').get_client_zone_iana()

  friendly_due_at: ember.computed 'due_at', ->
    date = @get 'due_at'
    return 'N/A' unless ember.isPresent(date)
    @get('ttz').format date, format: 'MMMM Do YYYY, h:mm z', zone: @get('ttz').get_client_zone_iana()

  # ### Components
  c_date_picker:      ns.to_p 'common', 'date_picker'
  c_time_picker:      ns.to_p 'common', 'time_picker'
  c_logistics_phases: ns.to_p 'builder', 'steps', 'logistics', 'phases'

  # ### Callbacks

  init: ->
    @_super()
    @load_assignment().then => @set_all_data_loaded()

  load_assignment: ->
    # May double load if refreshing page, but ensures that assignment is loaded (e.g. coming from templates phase).
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      model.get(ns.to_p('phases')).then (phases) =>
        return resolve() if phases.get('length') > 0
        @tc.query(ns.to_p('assignment'), {id: model.get('id'), action: 'load'}, single: true).then (assignment) =>
          resolve()

  callbacks_next_step: ->
    new ember.RSVP.Promise (resolve, reject) =>
      assignment    = @get 'model'
      instructions  = @get 'instructions'
      builder       = @get 'builder'
      ns_assignment = ns.to_p 'assignment'
      query         = 
        id:               assignment.get 'id'
        action:           ''
        verb:             'put'
        configuration:    @get_configuration_values()
        "#{ns_assignment}":
          instructions: instructions

      builder.set_is_saving()
      @totem_messages.show_loading_outlet()
      @tc.query(ns.to_p('assignment'), query, single: true).then (assignment) =>
        console.log '[steps:logistics] Assignment: ', assignment
        builder.reset_is_saving()
        @get('builder').transition_to_next_step()
        resolve()
      , (error) => @get('builder').encountered_save_error(error)
    , (error) => console.error 'Error caught in details step.'

  get_configuration_values: ->
    values =
      due_at:     @get 'due_at'
      release_at: @get 'release_at'

  save_phases: ->
    new ember.RSVP.Promise (resolve, reject) =>




  save_phase: (phase, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      ns_phase      = ns.to_p('phase')
      store         = @totem_scope.get_store()
      query         = 
        id:               phase.get 'id'
        action:           ''
        verb:             'put'
        configuration:    options.configuration
        "#{ns_phase}":
          default_state: options.default_state
          unlock_at:     options.unlock_at
          due_at:        options.due_at

      @tc.query(ns.to_p('phase'), query, single: true).then (phase) =>
        resolve(phase)


  # ### Date / time helpers
  set_date: (property, date) ->
    console.log date, date.obj
    @set property, date.obj

  set_time: (property, time) ->
      date     = @get property
      date     = @get('ttz').set_date_to_time date, time
      new_date = new Date(date.getTime()) # Must duplicate to update the bindings.
      @set property, new_date

  get_registered_phases: -> @get 'registered_phases'

  actions:
    select_release_date: (date) -> @set_date 'release_at', date
    select_release_time: (time) -> @set_time 'release_at', time
    select_due_date:     (date) -> @set_date 'due_at', date
    select_due_time:     (time) -> @set_time 'due_at', time

    select_unlock_at: (date) -> @set 'unlock_at', date

    toggle_phase_logistics: -> @toggleProperty 'showing_phase_logistics'


    register_phase: (component) ->
      @get_registered_phases().pushObject component
