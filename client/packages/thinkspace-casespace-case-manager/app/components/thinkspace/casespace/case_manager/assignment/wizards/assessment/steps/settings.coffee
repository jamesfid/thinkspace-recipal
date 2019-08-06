import ember      from 'ember'
import ns         from 'totem/ns'
import util       from 'totem/util'
import base       from 'thinkspace-casespace-case-manager/components/wizards/steps/base'
import val_mixin  from 'totem/mixins/validations'

export default base.extend val_mixin,
  # Properties
  step:         'settings'
  qualitative:  null
  quantitative: null
  options:      null
  methodology:  null
  type:         ember.computed.reads 'options.type'
  page_title:   ember.computed.reads 'model.title'

  has_individual_comments: false
  is_michaelsen:           ember.computed.equal 'methodology', 'michaelsen'
  is_custom:               ember.computed.equal 'methodology', 'custom'
  has_methodology:         ember.computed.or 'is_michaelsen', 'is_custom'

  methodology_types:
    michaelsen: ['balance']
    fink:       []
    custom:     ['categories', 'balance', 'free']

  # Components
  c_quantitative: ns.to_p 'case_manager', 'assignment', 'wizards', 'assessment', 'steps', 'settings', 'quantitative'
  c_qualitative:  ns.to_p 'case_manager', 'assignment', 'wizards', 'assessment', 'steps', 'settings', 'qualitative'

  methodologies:
    michaelsen:
      options:
        points:
          min:         0
          max:         15
          per_member:  10
          different:   false
          descriptive:
            enabled: false
            values:  []
        type: 'balance'
      qualitative: [
        { id: 1, label: 'Indicate specifically how this person contributes to group success.', type: 'textarea', feedback_type: 'positive' }
        { id: 2, label: 'Make constructive suggestions about how this person could better contribute to group success.', type: 'textarea', feedback_type: 'constructive' }
      ]
      quantitative: [
        { id: 1, label: 'Score', type: 'range' }
      ]
      properties:
        has_individual_comments: true
    custom:
      options:      {}
      qualitative:  []
      quantitative: []

  init: ->
    @_super()
    @init_defaults()

  init_defaults: ->
    @set 'qualitative',  [] 
    @set 'quantitative', []
    @set 'options',      {} 

  get_store: -> @container.lookup('store:main')

  set_value: (path, value, options={}) -> 
    value = parseInt(value) if options.number
    util.set_path_value(@, path, value)

  set_options_type: ->
    options      = @get 'options'
    options.type = @get 'type'

  get_assessment_value: ->
    options      = @get 'options'
    qualitative  = @get 'qualitative'
    quantitative = @get 'quantitative'
    type         = @get 'type'
    @set_options_type()

    switch type
      when 'balance'
        @set_balance_quantitative()
      when 'free'
        @set_free_quantitative()

    value =
      options:      options
      qualitative:  qualitative
      quantitative: quantitative

  get_quantitative_slider: -> { id: 1, label: 'Score', type: 'range' }

  set_balance_quantitative: ->
    item         = @get_quantitative_slider()
    quantitative = @get 'quantitative'
    quantitative.clear()
    quantitative.pushObject(item)

  set_free_quantitative: ->
    @set_balance_quantitative() # Same as balance.

  get_next_id: (items) ->
    if ember.isPresent(items)
      id = parseInt items.mapBy('id').sort().pop()
      id += 1
    else
      id = 1
    id

  get_types_for_methodology: (type) ->
    methodology = @get 'methodology'
    @get("methodology_types.#{methodology}")

  is_valid_type_for_methodology: (type) ->
    types       = @get_types_for_methodology(type)
    return false unless ember.isPresent(types)
    types.contains(type)

  set_type_for_methodology: (type) ->
    types      = @get_types_for_methodology(type)
    first_type = types.get('firstObject')
    if @is_valid_type_for_methodology(type) then @set('type', type) else @set('type', first_type)

  actions:
    complete: ->
      wizard_manager = @get('wizard_manager')
      assessment = @get_store().createRecord ns.to_p('tbl:assessment'),
        value: @get_assessment_value()
      console.log "[tbl-wizard-settings] Assessment generated as: ", assessment
      wizard_manager.send_action 'set_assessment', assessment
      wizard_manager.send_action 'complete_step', @get('step')

    set_methodology: (methodology) ->
      defaults     = @get("methodologies.#{methodology}")
      options      = ember.get defaults, 'options'
      qualitative  = ember.get defaults, 'qualitative'
      quantitative = ember.get defaults, 'quantitative'
      @set 'methodology',  methodology
      @set 'options',      options
      @set 'qualitative',  qualitative
      @set 'quantitative', quantitative
      @set_type_for_methodology @get('type')

      if ember.isPresent(defaults.properties)
        for property of defaults.properties
          @set property, defaults.properties[property]

      console.log "Methodolgy set: ", @

    add_qualitative_item: (feedback_type='positive') ->
      items = @get 'qualitative'
      item  = 
        id:            @get_next_id(items)
        label:         ''
        feedback_type: feedback_type
        type:          'textarea'
      items.pushObject(item)

    remove_qualitative_item: (item) ->
      items = @get 'qualitative'
      items.removeObject(item) if items.contains(item)

    add_quantitative_item: ->
      items = @get 'quantitative'
      item  = 
        id:            @get_next_id(items)
        label:         ''
        type:          'range'
      items.pushObject(item)

    toggle_has_individual_comments: -> @toggleProperty('has_individual_comments')

    set_points_different:           (value) ->  @set_value('options.points.different', value)
    set_points_descriptive_enabled: (value) ->  @set_value('options.points.descriptive.enabled', value)
    set_points_descriptive_values:  (values) -> @set_value('options.points.descriptive.values', values)
    set_points_per_member:          (value) ->  @set_value('options.points.per_member', value, number: true)
    set_points_max:                 (value) ->  @set_value('options.points.max', value, number: true)
    set_points_min:                 (value) ->  @set_value('options.points.min', value, number: true)
    set_type:                       (type) ->   @set_type_for_methodology(type)