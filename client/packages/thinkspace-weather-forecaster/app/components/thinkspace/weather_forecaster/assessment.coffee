import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  c_assessment_show: ns.to_p 'wf:assessment', 'show'
  c_attempts:        ns.to_p 'wf:assessment', 'attempts'
  c_top_forecasts:   ns.to_p 'wf:assessment', 'top_forecasts'
  c_help_tip:        ns.to_p 'wf:assessment', 'help_tip'

  show_help:          false
  show_attempts:      true
  show_top_forecasts: false

  current_forecast:  null
  selected_forecast: null
  view_forecast:     ember.computed 'current_forecast', 'selected_forecast', -> @get('selected_forecast') or @get('current_forecast')

  help_tip: null

  actions:
    show_help: (help) ->
      @set 'help_tip', help
      @set 'show_help', true

    hide_help: -> @set 'show_help', false

    select_forecast: (forecast) ->
      if forecast == @get('current_forecast')
        @set 'selected_forecast', null
      else
        @set 'selected_forecast', forecast

    select_attempts: ->
      @set 'show_top_forecasts', false
      @set 'show_attempts', true

    select_top_forecasts: ->
      @set 'show_attempts', false
      @set 'show_top_forecasts', true

  didInsertElement: ->
    @totem_messages.show_loading_outlet()
    @get_assessment_current_forecast().then (forecast) =>
      @get_assessment_forecast_attempts().then =>
        @set 'current_forecast', forecast
        @totem_messages.hide_loading_outlet()
    , (error) =>
      assessment = @get('model')
      @totem_messages.api_failure(error, source: @, model: assessment)

  get_assessment_current_forecast: ->
    new ember.RSVP.Promise (resolve, reject) =>
      assessment  = @get('model')
      query       = @totem_scope.get_view_query(assessment, action: 'current_forecast')
      query.model = assessment
      ajax.object(query).then (payload) =>
        type = ns.to_p 'wf:forecast'
        forecast = payload[type]
        assessment.store.pushPayload(payload)
        assessment.store.find(type, forecast.id).then (forecast) =>
          resolve(forecast)
    , (error) => reject(error)

  get_assessment_forecast_attempts: ->
    new ember.RSVP.Promise (resolve, reject) =>
      assessment = @get('model')
      query      = @totem_scope.get_view_query(assessment, sub_action: 'forecast_attempts')
      assessment.store.find(ns.to_p('wf:assessment'), query).then =>
        resolve()
    , (error) => reject(error)

  top_forecasts: ember.computed 'current_forecast', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      assessment            = @get('model')
      query                 = @totem_scope.get_view_query(assessment)
      query.auth.sub_action = 'top_forecasts'
      query.data            = {}
      query.data.auth       = query.auth
      query.model           = assessment
      delete(query.auth)
      ajax.object(query).then (payload) =>
        users      = payload.top_forecasts or []
        user.score = parseInt(user.score) for user in users
        resolve(users)
        @set 'have_top_forecasts', true
      , (error) => reject(error)
    ds.PromiseArray.create promise: promise
