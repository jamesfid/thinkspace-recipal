module Thinkspace
  module WeatherForecaster
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::WeatherForecaster
      engine_name 'thinkspace_weather_forecaster'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_weather_forecaster',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'tools',
        )
      end

    end
  end
end