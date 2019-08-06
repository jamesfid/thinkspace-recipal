import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  admin: ember.inject.service(ns.to_p 'lab', 'admin')

  model: ember.computed.reads 'admin.action_overlay_model'

  form_heading: ember.computed ->
    type    = @get('model.admin_type')
    @t("builder.lab.admin.edit_#{type}")

  actions:
    cancel: -> @get('admin').set_action_overlay_off()

    save: ->
      admin  = @get('admin')
      result = @get('model')
      admin.save_result(result).then => @send 'cancel'
