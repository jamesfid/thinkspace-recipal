import ember from 'ember'
import ns    from 'totem/ns'
import val_mixin from 'totem/mixins/validations'
import base_component from 'thinkspace-base/components/base'

export default ember.Component.extend val_mixin,
  classNameBindings: ['no_errors::thinkspace-weather-forecaster_error']

  no_errors: ember.computed.or 'is_valid', 'is_view_only'

  c_radio_item: ns.to_p 'wf:response', 'radio', 'item'

  choices: ember.computed -> @get('metadata.choices')

  input_value: null

  didInsertElement: -> @set 'input_value', @get('model.value.input')

  actions:
    check: (id) ->
      return if @get('is_view_only')
      @set 'input_value', id
      @sendAction 'save', id

    uncheck: ->
      return if @get('is_view_only')
      @set 'input_value', null
      @sendAction 'save', null

  validations:
    input_value:
      presence:
        message: 'You must select one of the above options'