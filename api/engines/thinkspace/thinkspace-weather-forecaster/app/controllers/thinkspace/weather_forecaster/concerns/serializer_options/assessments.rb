module Thinkspace
  module WeatherForecaster
    module Concerns
      module SerializerOptions
        module Assessments

            def show(serializer_options)
              # serializer_options.remove_association  :ownerable
              serializer_options.remove_association  :authable
              serializer_options.remove_association  :thinkspace_weather_forecaster_forecast_day
              serializer_options.remove_association  :thinkspace_weather_forecaster_assessment_items, scope: :thinkspace_weather_forecaster_item
              serializer_options.blank_association   :thinkspace_weather_forecaster_forecasts
              serializer_options.include_association :thinkspace_weather_forecaster_items, scope: :root
              serializer_options.include_association :thinkspace_weather_forecaster_assessment_items, scope: :root
              serializer_options.include_association :thinkspace_weather_forecaster_station
            end

            def forecast_common_serializer_options(serializer_options)
              serializer_options.remove_all_except(
                :thinkspace_weather_forecaster_assessment,
                :thinkspace_weather_forecaster_responses,
                :thinkspace_weather_forecaster_assessment_items
              )
            end

            def view(serializer_options)
              forecast_common_serializer_options(serializer_options)
              serializer_options.blank_association   :thinkspace_weather_forecaster_responses
            end

            def current_forecast(serializer_options)
              forecast_common_serializer_options(serializer_options)
              serializer_options.include_association :thinkspace_weather_forecaster_responses
            end

        end
      end
    end
  end
end
