import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  admin: ember.inject.service(ns.to_p 'lab', 'admin')

  result_type:  ember.computed.reads 'model.admin_type'
  form_heading: ember.computed -> @t('builder.lab.admin.edit_category')

  model: ember.computed ->
    admin    = @get('admin')
    mock     = admin.get_mock_new_category_record()
    category = admin.get_selected_category()
    admin.clone_category_values(mock, category)

  actions:
    cancel: -> @get('admin').set_action_overlay_off()

    save: ->
      admin    = @get('admin')
      category = admin.get_selected_category()
      mock     = @get('model')
      admin.save_category(category, values: mock).then =>
        admin.reset_selected_category()
        @send 'cancel'
