import ember from 'ember'
import ns    from 'totem/ns'
import base  from './base'
import val_mixin from 'totem/mixins/validations'

export default base.extend val_mixin,

  lower_value: null
  upper_value: null

  init_values: ->
    [lower, upper] = @get_model_value_path()
    @set 'lower_value', lower
    @set 'upper_value', upper

  get_display_value: ->
    [lower, upper] = @get_model_value_path()
    return "#{lower}-#{upper}"  if ember.isPresent(lower) and ember.isPresent(upper)
    return "#{lower}"           if ember.isPresent(lower)
    "#{upper}"

  form_valid: ->
    new ember.RSVP.Promise (resolve, reject) =>
      return reject() unless @get('is_valid')
      @set_model_value_path [@get('lower_value'), @get('upper_value')]
      resolve()