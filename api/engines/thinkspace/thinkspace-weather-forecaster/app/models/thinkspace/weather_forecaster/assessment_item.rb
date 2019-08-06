module Thinkspace
  module WeatherForecaster
    class AssessmentItem < ActiveRecord::Base        
      totem_associations
      validates_presence_of :thinkspace_weather_forecaster_item, :thinkspace_weather_forecaster_assessment
    end
  end
end
