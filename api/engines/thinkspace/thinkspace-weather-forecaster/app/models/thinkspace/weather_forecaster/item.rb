module Thinkspace
  module WeatherForecaster
    class Item < ActiveRecord::Base        
      totem_associations
      validates_presence_of :name, :score_var
    end
  end
end
