module Thinkspace
  module WeatherForecaster
    module Concerns
      module SerializerOptions
        module Responses

            def common_serializer_options(serializer_options)
              serializer_options.remove_all_except   :thinkspace_weather_forecaster_forecast, :thinkspace_weather_forecaster_assessment_item
            end

            def create(serializer_options)
              common_serializer_options(serializer_options)
            end

            def update(serializer_options)
              common_serializer_options(serializer_options)
            end

        end
      end
    end
  end
end
