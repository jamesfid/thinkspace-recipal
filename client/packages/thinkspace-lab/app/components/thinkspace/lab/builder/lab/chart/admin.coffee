import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  init: ->
    @_super()
    admin = @get('admin')
    chart = @get('model')
    admin.clear()
    admin.set_admin_component(@)
    admin.set_store(chart.store)
    admin.set_chart(chart)
    admin.set 't', @t  # set for i18n lookups
    # admin.test_ui_on()  # use to test the UI and not send ajax requests

  admin: ember.inject.service(ns.to_p 'lab', 'admin')

  is_active: false

  actions:
    select: -> @set 'is_active', true

    exit: -> @send 'clear_and_exit'

    clear_and_exit: ->
      admin = @get('admin')
      admin.set_action_overlay_off()
      admin.clear()
      @set 'is_active', false
