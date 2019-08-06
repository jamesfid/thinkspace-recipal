import ember from 'ember'
import ns    from 'totem/ns'
import util  from 'totem/util'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  admin: ember.inject.service(ns.to_p 'lab', 'admin')

  value_path: ember.computed.reads 'column.value_path'

  is_edit: ember.computed 'admin.result_value_edit_component', ->
    @get('admin').is_result_value_edit_component(@) or @get('result_edit')

  show_errors: ember.computed 'show_form_errors', ->
    return true unless @get('result_edit')
    @get 'show_form_errors'

  init: ->
    @_super()
    if @get('result_edit')
      @init_values()
      @get('admin').add_result_form_component(@)
    else
      paths = ember.makeArray @get('value_path')
      if ember.isPresent(paths)
        paths = paths.map (path) -> 'model.' + path
        ember.defineProperty @, 'display_value', ember.computed paths.join(','), ->
          @init_values()
          @get_display_value()

  get_model_value_path: ->
    model = @get('model')
    return null if ember.isBlank(model)
    path = @get('value_path')
    return null if ember.isBlank(path)
    if ember.isArray(path)
      path.map (p) => model.get(p)
    else
      model.get(path)

  set_model_value_path: (value) ->
    model = @get('model')
    return if ember.isBlank(model)
    paths = ember.makeArray @get('value_path')
    return if ember.isBlank(paths)
    values = ember.makeArray(value)
    ember.makeArray(paths).forEach (path, index) =>
      @set_path_value(model, path, values[index] or '')

  set_path_value: (model, path, value) -> util.set_path_value(model, path, value)

  # Should be overridden by each component.
  form_valid: -> new ember.RSVP.Promise (resolve, reject) => reject()

  # Default rollback function (e.g. call init_values).
  # A component should override this function if is not the correct default.
  # Note: A 'result' form edit creates a new components each time, so rollback is not need on a form cancel.
  rollback: -> @init_values()

  # sendAction Properties (result show).
  edit_value:   'edit_value'
  save_value:   'save_value'
  cancel_value: 'cancel_value'

  actions:
    edit: -> @sendAction 'edit_value', @

    save: ->
      @form_valid().then => @sendAction 'save_value'

    cancel: ->
      @rollback()
      @sendAction 'cancel_value'
