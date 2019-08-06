import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  admin: ember.inject.service(ns.to_p 'lab', 'admin')

  actions:
    cancel: -> @get('admin').set_action_overlay_off()

    delete: ->
      admin = @get('admin')
      admin.delete_category().then =>
        admin.set_chart_selected_category().then =>
          @send 'cancel'
