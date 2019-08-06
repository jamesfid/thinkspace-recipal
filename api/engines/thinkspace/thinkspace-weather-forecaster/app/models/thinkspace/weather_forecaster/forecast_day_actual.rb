module Thinkspace
  module WeatherForecaster
    class ForecastDayActual < ActiveRecord::Base        
      totem_associations

      validates_presence_of :thinkspace_weather_forecaster_forecast_day, :thinkspace_weather_forecaster_station

      # ###
      # ### Scopes.
      # ###

      def self.scope_by_forecast_day_id_and_station_id(forecast_day_id, station_id)
        find_by(forecast_day_id: forecast_day_id, station_id: station_id)
      end

      def self.scope_by_forecast(forecast)
        station = forecast.thinkspace_weather_forecaster_station
        scope_by_forecast_day_id_and_station_id(forecast.forecast_day_id, station.id)
      end

      # ###
      # ### Class Method Helpers.
      # ###

      def self.get_new_record(forecast_day_id, station_id)
        self.new(forecast_day_id: forecast_day_id, station_id: station_id)
      end

      # ###
      # ### Instance Methods.
      # ###

      def check_response(score_var, response_value)
        raise CheckResponseError, "Score var is blank."  if score_var.blank?
        actuals    = self.value || Hash.new
        var_actual = (actuals[score_var.to_s] || Hash.new).deep_symbolize_keys
        logic      = var_actual[:logic]  || ''
        actual     = var_actual[:actual]
        resp_val   = [response_value].flatten.compact
        case logic.to_sym
        when :equal, :and
          actual     = [actual].flatten.compact
          is_correct = (actual.sort == resp_val.sort)
        when :or
          actual     = [actual].flatten.compact
          is_correct = (resp_val - actual).blank? && (actual.present? && resp_val.present?)
        when :range
          raise CheckResponseError, "Range actual must be a hash e.g. actual: {min: 1, max:10}."  unless actual.is_a?(Hash)
          min  = actual[:min]
          max  = actual[:max]
          resp = resp_val.first
          case
          when !is_integer?(resp)
            is_correct = false
          when is_integer?(min) && is_integer?(max)
            is_correct = (resp.to_i >= min.to_i && resp.to_i <= max.to_i)
          when is_integer?(min)
            is_correct = (resp.to_i >= min.to_i)
          when is_integer?(max)
            is_correct = (resp.to_i <= max.to_i)
          else
            is_correct = false
          end
        else
          raise CheckResponseError, "Unknown logic value #{logic.inspect} for score var #{score_var.inspect} and var_actual #{var_actual.inspect}."
        end
        {is_correct: is_correct, var_actual: var_actual, score_var: score_var, response_value: response_value}
      end

      def is_integer?(val)
        return false if val.blank?
        val.to_s.match(/^[-|+]?\d+$/)
      end

      class CheckResponseError < StandardError; end

    end
  end
end
