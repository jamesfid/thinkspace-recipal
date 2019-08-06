import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  admin: ember.inject.service(ns.to_p 'lab', 'admin')

  model: ember.computed ->
    admin = @get('admin')
    type  = admin.get('new_result_type')
    admin.get_mock_new_result_record(type)

  form_heading: ember.computed ->
    type    = @get('admin.new_result_type')
    @t("builder.lab.admin.new_#{type}")

  actions:
    cancel: -> @get('admin').set_action_overlay_off()

    save: ->
      admin = @get('admin')
      admin.get_category_results().then (results) =>
        position = results.get('length') + 1
        mock     = @get('model')
        mock.set 'position', position
        result = admin.get_store().createRecord ns.to_p('lab:result')
        admin.save_result(result, values: mock).then => @send 'cancel'
