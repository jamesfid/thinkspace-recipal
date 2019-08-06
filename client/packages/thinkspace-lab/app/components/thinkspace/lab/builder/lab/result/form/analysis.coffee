import ember from 'ember'
import ns    from 'totem/ns'
import base  from './base'

export default base.extend

  selections:     null
  normal_label:   null
  correct_label:  null
  error_messages: null

  new_count: 0

  init_values: ->
    [selections, normal, correct] = @get_model_value_path()
    @set 'selections', @get_unbound_selections(selections)
    @set 'normal_label', @get_normal_label(normal)
    @set 'correct_label', @get_correct_label(correct)

  get_display_value: ->
    labels  = @get_selection_labels()
    normal  = @get('normal_label')
    correct = @get('correct_label')
    "(#{labels.join(',')}) (#{normal}) (#{correct})"

  actions:
    add_label: ->
      selections  = @get('selections')
      new_count   = @incrementProperty 'new_count'
      new_id      = "new_#{new_count}"
      class_input = "lab_analysis_#{new_id}"
      selections.pushObject({id: new_id, label: '', class: class_input})
      @set 'selections', selections
      ember.run.schedule 'afterRender', => $(".#{class_input}").focus()

    delete_label: (selection) -> @set 'selections', @get('selections').without(selection)

  form_valid: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @validate_selections().then (selections) =>
        @validate_correct(selections).then (correct) =>
          @validate_normal(selections).then (normal) =>
            @set_model_value_path [selections, normal, correct]
            resolve()
          , (error_messages) =>
            @set_error_messages(error_messages)
            reject()
        , (error_messages) =>
          @set_error_messages(error_messages)
          reject()
      , (error_messages) =>
        @set_error_messages(error_messages)
        reject()

  validate_selections: ->
    new ember.RSVP.Promise (resolve, reject) =>
      all_selections = @get('selections')
      return reject(@t 'builder.lab.admin.form.analysis.errors.selections_blank')  if ember.isBlank(all_selections)
      ids        = []
      selections = []
      all_selections.forEach (selection) =>
        label = selection.label
        if ember.isPresent(label)
          label = label.trim()
          id    = @label_to_id(label)
          return reject(@t 'builder.lab.admin.form.analysis.errors.duplicate_label', label)  if ids.contains(id)
          ids.push(id)
          selections.pushObject({id: id, label: label})
      resolve(selections)

  validate_correct: (selections) ->
    new ember.RSVP.Promise (resolve, reject) =>
      label = @get('correct_label')
      return reject(@t 'builder.lab.admin.form.analysis.errors.correct_blank') if ember.isBlank(label)
      label    = label.trim()
      id       = @label_to_id(label)
      selected = selections.findBy 'id', id
      return reject(@t 'builder.lab.admin.form.analysis.errors.correct_not_selectable', label)  unless ember.isPresent(selected)
      return reject(@t 'builder.lab.admin.form.analysis.errors.correct_not_selectable', label)  unless selected.label == label
      resolve(id)

  validate_normal: (selections) ->
    new ember.RSVP.Promise (resolve, reject) =>
      label = @get('normal_label')
      return reject(@t 'builder.lab.admin.form.analysis.errors.normal_blank') if ember.isBlank(label)
      label    = label.trim()
      id       = @label_to_id(label)
      selected = selections.findBy 'id', id
      return reject(@t 'builder.lab.admin.form.analysis.errors.normal_not_selectable', label)  unless ember.isPresent(selected)
      return reject(@t 'builder.lab.admin.form.analysis.errors.normal_not_selectable', label)  unless selected.label == label
      resolve(id)

  label_to_id: (label) -> (label or '').toLowerCase().replace(/\s/,'_')

  set_error_messages: (messages) -> @set 'error_messages', ember.makeArray(messages)

  get_unbound_selections: (selections) -> selections.map (selection) -> ember.merge({}, selection)
  get_selection_labels: ->
    labels = @get('selections').mapBy 'label'
    labels.map (label) -> '' + (label or '')
  
  get_correct_label: (correct) ->
    selection = @get('selections').findBy('id', correct) or {}
    '' + (selection.label or '')

  get_normal_label: (normal) ->
    selection = @get('selections').findBy('id', normal) or {}
    '' + (selection.label or '')

  rollback: ->
    @set 'error_messages', null
    @init_values()
