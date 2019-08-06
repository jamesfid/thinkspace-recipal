import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  c_attempt:  ns.to_p 'wf:assessment', 'attempt'
  c_forecast: ns.to_p 'wf:forecast', 'show'

  forecast_observer: ember.observer 'forecast', ->
    @get_forecast_responses().then =>
      @rerender()

  actions:
    show_help: (help_tip) -> @sendAction 'show_help', help_tip

  # If have multiple phases, need to reload the responses to set the response association on each forecast#show.
  get_forecast_responses: ->
    new ember.RSVP.Promise (resolve, reject) =>
      forecast = @get('forecast')
      query    = @totem_scope.get_view_query(forecast)
      @totem_messages.show_loading_outlet()
      forecast.store.find(ns.to_p('wf:forecast'), query).then =>
        @totem_messages.api_success source: @, model: forecast, action: 'save'
        @totem_messages.hide_loading_outlet()
        resolve()
    , (error) =>
      @totem_messages.api_failure error, source: @, model: forecast, action: 'save'
