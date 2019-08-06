import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  admin: ember.inject.service(ns.to_p 'lab', 'admin')

  model:        ember.computed -> @get('admin').get_mock_new_category_record()
  form_heading: ember.computed -> @t('builder.lab.admin.new_category')

  actions:
    cancel: -> @get('admin').set_action_overlay_off()

    save: ->
      admin = @get('admin')
      admin.get_chart_categories().then (categories) =>
        position = categories.get('length') + 1
        mock     = @get('model')
        mock.set 'position', position
        category = admin.get_store().createRecord ns.to_p('lab:category')
        admin.save_category(category, values: mock).then =>
          admin.set_selected_category(category)
          @send 'cancel'
