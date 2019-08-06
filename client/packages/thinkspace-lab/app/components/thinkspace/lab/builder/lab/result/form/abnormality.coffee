import ember from 'ember'
import ns    from 'totem/ns'
import base  from './base'
import val_mixin from 'totem/mixins/validations'

export default base.extend val_mixin,

  no_input: ember.computed.equal 'model.value.observations.abnormality.input_type', 'none'

  max_attempts:   null
  correct_values: null
  error_messages: null

  new_count: 0

  init_values: ->
    [correct, max] = @get_model_value_path()
    @set 'correct_values', @get_unbound_correct_values(correct)
    @set 'max_attempts', (max or 0) + 0

  get_display_value: ->
    correct = @get('correct_values').map (correct) -> correct.value
    max     = @get('max_attempts')
    correct = ['click to add']  if ember.isBlank(correct)
    "(#{correct.join(',')}) (#{max})"

  actions:
    add_label: ->
      correct     = @get('correct_values')
      new_count   = @incrementProperty 'new_count'
      new_id      = "new_#{new_count}"
      class_input = "lab_abnormality_#{new_id}"
      correct.pushObject({value: '', class: class_input})
      @set 'correct_values', correct
      ember.run.schedule 'afterRender', => $(".#{class_input}").focus()

    delete_label: (value) -> @set 'correct_values', @get('correct_values').without(value)

  form_valid: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @validate_correct_values().then (correct_values) =>
        @validate_max_attempts().then (max_attempts) =>
          max_attempts = 0  if ember.isBlank(correct_values)
          @set_model_value_path [correct_values, max_attempts]
          resolve()
        , (error_messages) =>
          @set_error_messages(error_messages)
          reject()
      , (error_messages) =>
        @set_error_messages(error_messages)
        reject()

  validate_correct_values: ->
    new ember.RSVP.Promise (resolve, reject) =>
      correct = ember.makeArray @get('correct_values')
      correct = correct.map (hash) -> (hash.value or '').trim()
      correct = correct.filter (element) -> ember.isPresent(element)
      correct = correct.uniq()
      resolve(correct)

  validate_max_attempts: ->
    new ember.RSVP.Promise (resolve, reject) =>
      max = @get('max_attempts') or 0
      return reject(@t 'builder.lab.admin.form.abnormality.errors.max_attempts') unless ('' + max).match(/^\d+$/)
      resolve parseInt(max)

  set_error_messages: (messages) -> @set 'error_messages', ember.makeArray(messages)

  get_unbound_correct_values: (correct) -> (correct or []).map (value) -> {value: '' + (value or '')}
  
  rollback: ->
    @set 'error_messages', null
    @init_values()

  validations:
    max_attempts:
      presence: true
      numericality: 
        onlyInteger:          true
        greaterThanOrEqualTo: 0
        # allowBlank:         true
        # lessThanOrEqualTo:  10
