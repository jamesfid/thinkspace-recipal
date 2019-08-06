module Thinkspace
  module WeatherForecaster
    module Concerns
      module SerializerOptions
        module Forecasts

            def common_serializer_options(serializer_options)
              serializer_options.remove_all_except(
                  :thinkspace_weather_forecaster_assessment,
                  :thinkspace_weather_forecaster_responses,
                  scope: :root
                )
            end

            def view(serializer_options)
              common_serializer_options(serializer_options)
              serializer_options.remove_all_except(
                  :thinkspace_weather_forecaster_forecast,
                  :thinkspace_weather_forecaster_assessment_item,
                  scope: :thinkspace_weather_forecaster_responses
                )
              serializer_options.include_association :thinkspace_weather_forecaster_responses
            end

            def update(serializer_options)
              common_serializer_options(serializer_options)
            end

        end
      end
    end
  end
end
