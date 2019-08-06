import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  admin: ember.inject.service(ns.to_p 'lab', 'admin')

  result_columns: ember.computed ->
    admin  = @get('admin')
    result = @get('model')
    type   = result.get('admin_type')
    admin.result_type_columns(result, type)

  show_form_errors: false

  actions:
    cancel: -> @sendAction 'cancel'

    save:   ->
      admin      = @get('admin')
      form_comps = admin.get_result_form_components()
      promises   = form_comps.map (comp) -> comp.form_valid()
      ember.RSVP.all(promises).then =>
        @sendAction 'save'
      , =>
        @set 'show_form_errors', true
