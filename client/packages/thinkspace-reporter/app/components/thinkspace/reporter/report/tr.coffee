import ember            from 'ember'
import ns               from 'totem/ns'
import base_component   from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Properties
  tagName: 'tr'
  model:   null # Report

  # ### Components
  c_loader: ns.to_p 'common', 'loader'

  # ### Routes
  r_assignments_reports_show: ns.to_r 'assignments', 'reports', 'show'

  actions:
    delete: ->
      @totem_messages.show_loading_outlet(message: 'Deleting report...')
      @get('model').destroyRecord().then =>
        @totem_messages.hide_loading_outlet()
