import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  admin: ember.inject.service(ns.to_p 'lab', 'admin')

  result_columns: ember.computed -> @get('admin').result_type_columns @get('model'), @get('model.admin_type')

  title_column: ember.computed.reads 'result_columns.firstObject'

  html_column:      ember.computed -> @get('result_columns').findBy 'source', 'result'
  html_column_span: ember.computed -> @get('admin.selected_category_headings.length') - 1

  action_dropdown_collection: ember.computed ->
    [
      {display: @t('builder.lab.admin.form.buttons.edit'),   action: 'edit'}
      {display: @t('builder.lab.admin.form.buttons.clone'),  action: 'clone'}
      {display: @t('builder.lab.admin.form.buttons.delete'), action: 'delete'}
    ]

  actions:

    edit: ->
      admin  = @get('admin')
      result = @get('model')
      admin.set_action_overlay_model(result)
      admin.set_action_overlay('c_result_edit')

    clone: ->
      admin  = @get('admin')
      result = @get('model')
      title  = 'clone:' + result.get('title')
      clone  = result.store.createRecord ns.to_p('lab:result')
      admin.save_result(clone, values: result, properties: {title: title}).then =>
        ember.run.schedule 'afterRender', =>
          admin.on_drop_result_reorder()

    delete: ->
      admin  = @get('admin')
      result = @get('model')
      admin.set_action_overlay_model(result)
      admin.set_action_overlay('c_result_delete')

    edit_value: (component) ->
      admin  = @get('admin')
      admin.set_result_value_edit_component(component)

    save_value: ->
      admin  = @get('admin')
      result = @get('model')
      admin.save_result(result).then => admin.clear_overlay_values()

    cancel_value: -> 
      admin  = @get('admin')
      admin.clear_overlay_values()

