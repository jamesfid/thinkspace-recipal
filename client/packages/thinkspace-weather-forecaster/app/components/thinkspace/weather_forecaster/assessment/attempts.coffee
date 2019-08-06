import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  c_attempt_show: ns.to_p 'wf:assessment', 'attempt', 'show'

  forecast_attempts: ember.computed -> @get('model.forecasts_by_date')

  actions:
    select: (forecast) -> @sendAction 'select', forecast
