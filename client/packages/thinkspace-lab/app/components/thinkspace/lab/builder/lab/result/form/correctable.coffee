import ember from 'ember'
import ns    from 'totem/ns'
import base  from './base'
import val_mixin from 'totem/mixins/validations'

export default base.extend val_mixin,

  max_attempts:   null
  correct_value:  null
  error_messages: null

  init_values: ->
    [correct, max] = @get_model_value_path()
    @set 'correct_value', correct
    @set 'max_attempts', max

  get_display_value: ->
    [correct, max] = @get_model_value_path()
    correct = ['click to add']  if ember.isBlank(correct)
    "(#{correct}) (#{max})"

  form_valid: ->
    new ember.RSVP.Promise (resolve, reject) =>
      return reject() unless @get('is_valid')  # does not pass base field validations
      @validate_correct_value().then (correct) =>
        @validate_max_attempts().then (max_attempts) =>
          @set_model_value_path [correct, max_attempts]
          resolve()
        , (error_messages) =>
          @set_error_messages(error_messages)
          reject()
      , (error_messages) =>
        @set_error_messages(error_messages)
        reject()

  validate_correct_value: ->
    new ember.RSVP.Promise (resolve, reject) =>
      correct = @get('correct_value') or ''
      correct = correct.trim()
      resolve(correct)

  validate_max_attempts: ->
    new ember.RSVP.Promise (resolve, reject) =>
      max = @get('max_attempts') or 0
      return reject(@t 'builder.lab.admin.form.correctable.errors.max_attempts') unless ('' + max).match(/^\d+$/)
      resolve parseInt(max)

  set_error_messages: (messages) -> @set 'error_messages', ember.makeArray(messages)

  validations:
    correct_value:
      presence: true
      numericality: 
        greaterThanOrEqualTo: 0
    max_attempts:
      presence: true
      numericality: 
        onlyInteger:          true
        greaterThanOrEqualTo: 0
        # allowBlank:         true
        # lessThanOrEqualTo:  10
