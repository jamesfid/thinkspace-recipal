import ember from 'ember'
import ns    from 'totem/ns'
import base  from './base'
import val_mixin from 'totem/mixins/validations'

export default base.extend val_mixin,

  column_value: null

  init_values: -> @set 'column_value', @get_model_value_path()

  get_display_value: -> @get_model_value_path()

  form_valid: ->
    new ember.RSVP.Promise (resolve, reject) =>
      return reject()  unless @get('is_valid')
      @set_model_value_path @get('column_value')
      resolve()

  # Disabling to allow empty inputs.
  # validations:
  #   column_value:
  #     presence: true