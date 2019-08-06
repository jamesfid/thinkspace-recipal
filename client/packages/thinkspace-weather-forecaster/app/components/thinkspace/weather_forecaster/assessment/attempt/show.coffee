import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  ttz: ember.inject.service()

  is_selected:  ember.computed 'forecast', -> @get('model') == @get('forecast')
  is_current:   ember.computed 'forecast', -> @get('model') == @get('current_forecast')
  is_completed: ember.computed.bool 'model.completed'

  forecast_at: ember.computed -> @get('ttz').format(@get('model.forecast_at'), format: 'MMMM DD, YYYY')

  forecast_score: ember.computed ->
    if @get('is_current') or (not @get 'model.locked')
      '--'  # current forecast or a forecast that has not yet been scored
    else
      @get('model.score')

  actions:
    select: -> @sendAction 'select', @get('model')
