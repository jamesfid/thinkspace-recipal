module Thinkspace
  module WeatherForecaster
    module Api
      class ResponsesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options
        before_filter :authorize_change

        def create
          @response.value = get_params_response_value
          controller_save_record(@response)
        end

        def update
          @response.value = get_params_response_value
          controller_save_record(@response)
        end

        private

        # The params value must be a hash with an 'input' key e.g. {input: 'some-value'}.
        # The 'input' value can be a string, array, hash, etc.
        def get_params_response_value
          value = params_root[:value]
          access_denied "Response value is not a hash #{value.inspect}."  unless value.kind_of?(Hash)
          access_denied "Response value hash does not have an input key #{value.inspect}."  unless value.has_key?(:input)
          value
        end

        def authorize_change
          forecast        = @response.thinkspace_weather_forecaster_forecast
          assessment_item = @response.thinkspace_weather_forecaster_assessment_item
          access_denied "Response forecast is blank."         if forecast.blank?
          access_denied "Response assessment item is blank."  if assessment_item.blank?
          access_denied "Response forecast is locked."        if forecast.is_locked?
          authorize_assessment_item(forecast, assessment_item)
          authorize_ownerable(forecast)
          authorize_create_not_duplicate(forecast, assessment_item)  if totem_action_authorize.is_create?
        end

        def authorize_assessment_item(forecast, assessment_item)
          is_for_forecast = forecast.thinkspace_weather_forecaster_assessment_items.where(id: assessment_item.id).exists?
          access_denied "Response assessment item does not belong to the forecast."  unless is_for_forecast
        end

        def authorize_ownerable(forecast)
          params_ownerable   = totem_action_authorize.params_ownerable
          forecast_ownerable = forecast.ownerable
          access_denied "Response params ownerable does not match the forecast ownerable."  unless params_ownerable == forecast_ownerable
        end

        def authorize_create_not_duplicate(forecast, assessment_item)
          id     = assessment_item.id
          exists = forecast.thinkspace_weather_forecaster_responses.where(assessment_item_id: id).exists?
          access_denied "Response is a duplicate for the assessment item [id: #{id}]."  if exists
        end

        def access_denied(message)
          raise_access_denied_exception(message, totem_action_authorize.action, @response)
        end

      end
    end
  end
end
