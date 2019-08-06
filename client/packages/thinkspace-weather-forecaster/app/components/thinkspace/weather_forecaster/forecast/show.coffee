import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  c_assessment_item: ns.to_p 'wf:forecast', 'assessment_item'

  show_errors: true

  is_locked:    ember.computed.bool 'model.is_locked'
  is_view_only: ember.computed.or   'totem_scope.is_view_only', 'is_locked'

  actions:
    show_help: (help_tip) -> @sendAction 'show_help', help_tip

    save: (response, values) -> @save_response(response, values)

    submit: ->
      @set 'show_errors', true
      @save_forecast()

  save_forecast: ->
    return if @get('is_view_only')
    forecast = @get('model')
    return unless forecast
    forecast.save().then =>
      @totem_messages.api_success(source: @, model: forecast, action: 'save', i18n_path: ns.to_o('wf:forecast', 'save'))
    , (error) => 
      @totem_messages.api_failure(error, source: @, model: forecast)

  save_response: (response, values) ->
    return if @get('is_view_only')
    return unless response
    response.set 'value', input: values
    response.save().then =>
      @totem_messages.api_success(source: @, model: response, action: 'save', i18n_path: ns.to_o('wf:response', 'save'))
    , (error) => 
      @totem_messages.api_failure(error, source: @, model: response)
