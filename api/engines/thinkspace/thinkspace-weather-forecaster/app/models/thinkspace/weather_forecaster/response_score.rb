module Thinkspace
  module WeatherForecaster
    class ResponseScore < ActiveRecord::Base        
      totem_associations
      has_paper_trail
      validates_presence_of :thinkspace_weather_forecaster_response
    end
  end
end
