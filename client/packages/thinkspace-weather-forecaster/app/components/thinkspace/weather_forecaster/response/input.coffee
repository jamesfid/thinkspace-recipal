import ember from 'ember'
import ns    from 'totem/ns'
import val_mixin from 'totem/mixins/validations'
#import base_component from 'thinkspace-base/components/base'

export default ember.Component.extend val_mixin,
  classNameBindings: ['no_errors::thinkspace-weather-forecaster_error']

  no_errors: ember.computed.or 'is_valid', 'is_view_only'

  input_value: null

  input_attributes: ember.computed -> @get('metadata.attributes')

  is_correct_class:  null
  has_score:         ember.computed.reads 'model.has_score'
  has_score_message: ember.computed ->
    if @get('model.is_correct')
      @set 'is_correct_class', 'correct'
      null
    else
      @set 'is_correct_class', 'incorrect'
      actual = @get('model.actual')
      if @get('model.logic') == 'range'
        "Correct value is between '#{actual.min}' and '#{actual.max}'"
      else
        "Correct value is '#{actual}'"

  focusOut: ->
    @validate().then =>
      @sendAction 'save', @get('input_value')  if @get('is_valid')

  didInsertElement: ->
    item_validations = @get('metadata.validations')
    if item_validations
      rules = @camelize_validation_keys(item_validations)
      @set_validation_rules(input_value: rules)
    @set 'input_value', @get('model.value.input') or @get('input_attributes.value')

  validations:
    input_value:
      presence:
        message: 'You must enter a response'