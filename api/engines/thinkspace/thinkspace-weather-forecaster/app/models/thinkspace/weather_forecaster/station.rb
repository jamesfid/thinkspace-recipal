module Thinkspace
  module WeatherForecaster
    class Station < ActiveRecord::Base        
      totem_associations
      validates :location, presence: true, uniqueness: {scope: :source}
    end
  end
end
