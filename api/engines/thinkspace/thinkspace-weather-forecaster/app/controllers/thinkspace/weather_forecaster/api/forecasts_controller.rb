module Thinkspace
  module WeatherForecaster
    module Api
      class ForecastsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options
        before_filter :authorize_ownerable

        def update
          access_denied "Forecast is locked [time: #{Time.now}]."  if @forecast.is_locked?
          @forecast.attempts += 1
          @forecast.set_completed
          controller_save_record(@forecast)
        end

        def view
          controller_render_view(@forecast)
        end

        private

        def authorize_ownerable
          params_ownerable   = totem_action_authorize.params_ownerable
          forecast_ownerable = @forecast.ownerable
          access_denied "Response params ownerable does not match the forecast ownerable."  unless params_ownerable == forecast_ownerable
        end

        def access_denied(message)
          raise_access_denied_exception(message, totem_action_authorize.action, @forecast)
        end

      end
    end
  end
end
