module Thinkspace
  module WeatherForecaster
    module Api
      class AssessmentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options

        def show
          controller_render(@assessment)
        end

# TODO: Get forecasts for the last five 'forecast days' or last 5 forecasts submitted?  Only 'locked' e.g. graded?
          # forecast_day_class = current_ability.thinkspace_weather_forecaster_forecast_day_class
          # forecast_days      = forecast_day_class.previous_forecast_days(5)
          # forecasts          = @assessment.
          #   thinkspace_weather_forecaster_forecasts.
          #   where(ownerable: ownerable, thinkspace_weather_forecaster_forecasts: {forecast_day_id: forecast_days})

        def view
          ownerable  = totem_action_authorize.params_ownerable
          sub_action = totem_action_authorize.sub_action
          case sub_action
          when :forecast_attempts
            view_forecast_attempts(ownerable)
          when :top_forecasts
            view_top_forecasts(ownerable)
          else
            access_denied "Unknown assessment view sub action #{sub_action.inspect}."
          end
        end

        def current_forecast
          ownerable = totem_action_authorize.params_ownerable
          forecast  = @assessment.find_or_create_current_day_forecast(ownerable, current_user)
          access_denied "Forecast for current day not available."  if forecast.blank?
          controller_render_view(forecast)
        end

        private

        def view_forecast_attempts(ownerable)
          forecasts = @assessment.previous_forecasts(ownerable)
          controller_render_view(forecasts)
        end

        def view_top_forecasts(ownerable)
          top_forecasts = @assessment.top_forecasts_json(10)
          controller_render_json(top_forecasts: top_forecasts)
        end

        def access_denied(message)
          raise_access_denied_exception(message, totem_action_authorize.action, @assessment)
        end

      end
    end
  end
end
