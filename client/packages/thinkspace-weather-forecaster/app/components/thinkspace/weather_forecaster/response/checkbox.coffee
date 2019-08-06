import ember from 'ember'
import ns    from 'totem/ns'
import val_mixin from 'totem/mixins/validations'
#import base_component from 'thinkspace-base/components/base'

export default ember.Component.extend val_mixin,
  classNameBindings: ['no_errors::thinkspace-weather-forecaster_error']

  no_errors: ember.computed.or 'is_valid', 'is_view_only'

  c_checkbox_item: ns.to_p 'wf:response', 'checkbox', 'item'

  choices: ember.computed -> @get('metadata.choices')

  input_values: null

  didInsertElement: ->
    if item_validations = @get('metadata.validations')
      rules = @get_validation_rules_from_metadata(item_validations)
      @set_validation_rules(input_values: rules)
    @set 'input_values', ember.makeArray @get('model.value.input')

  get_input_values: -> @get 'input_values'

  actions:
    check: (id) ->
      return if @get('is_view_only')
      @add_id(id)
      @validate().then =>
        @sendAction 'save', @get_input_values()
      , =>
        @remove_id(id)

    uncheck: (id) ->
      return if @get('is_view_only')
      @remove_id(id)
      @validate().then =>
        @sendAction 'save', @get_input_values()
      , =>
        @add_id(id)

  add_id: (id) ->
    values = @get_input_values()
    values.pushObject(id)  unless values.contains(id)

  remove_id: (id) ->
    values = @get_input_values()
    index  = values.indexOf(id)
    values.removeAt(index)  if index?

  # If required, metadata validations must in the format:
  # metadata: {length: {minimum: #, maximum: #, message: ''}}
  get_validation_rules_from_metadata: (validation) ->
    return null unless validation
    length = validation.length or {}
    min    = length.minimum or null
    max    = length.maximum or null
    msg    = length.message or null
    {inline: @input_values_min_max_validator(min, max, msg)}

  input_values_min_max_validator: (min, max, msg) ->
    @inline_validator() ->
      length = @get('input_values.length')
      return null unless length?
      switch
        when (min? and max?) and (length < min or length > max)
          msg or "You must select between #{min} and #{max} items"
        when min? and length < min
          msg or "You must select at least #{min} items"
        when max? and length > max
          msg or "You must select less than #{max} items"
        else
          null