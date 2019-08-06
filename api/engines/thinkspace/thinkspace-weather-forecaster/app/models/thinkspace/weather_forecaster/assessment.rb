module Thinkspace
  module WeatherForecaster
    class Assessment < ActiveRecord::Base        
      totem_associations

      validates_presence_of :title, :thinkspace_weather_forecaster_station, :authable

      # ###
      # ### Scopes.
      # ###

      def self.to_score
        joins(:thinkspace_weather_forecaster_forecasts).
        merge(Forecast.to_score).
        order(:id).uniq
      end

      def self.to_rescore
        joins(:thinkspace_weather_forecaster_forecasts).
        merge(Forecast.to_rescore).
        order(:id).uniq
      end

      def self.scope_by_assessment_item_ids(ids)
        joins(:thinkspace_weather_forecaster_assessment_items).
        where(thinkspace_weather_forecaster_assessment_items: {id: ids})
      end

      # ###
      # ### Instance Methods.
      # ###

      def find_or_create_current_day_forecast(ownerable, user=nil)
        raise FindOrCreateError, "Forecast ownerable is blank for assessment [#{self.inspect}]."  if ownerable.blank?
        forecast = self.thinkspace_weather_forecaster_forecasts.find_ownerable_current_day(ownerable)
        if forecast.blank?
          forecast_day = forecast_day_class.find_or_create_current_forecast_day
          return nil if forecast_day.blank? || forecast_day.is_locked?
          forecast = thinkspace_weather_forecaster_forecasts.create(
            ownerable:       ownerable,
            forecast_day_id: forecast_day.id,
            user_id:         user && user.id,
            state:           forecast_day.default_state
          )
          raise FindOrCreateError, "Could not find or create forecast for assessment [errors: #{forecast.errors.messages}] [#{self.inspect}] [ownerable: #{ownerable.inspect}]."  if forecast.errors.present?
        end
        raise FindOrCreateError, "Could not find or create forecast for assessment [#{self.inspect}] [ownerable: #{ownerable.inspect}]."  if forecast.blank?
        forecast
      end

      def previous_forecasts(ownerable, number_of_forecasts=nil)
        scope = self.thinkspace_weather_forecaster_forecasts.
                scope_by_ownerable(ownerable).
                scope_by_state_attempts.
                scope_and_order_by_previous_forecast_days
        scope = scope.limit(number_of_forecasts) if number_of_forecasts.present?
        scope
      end

      def top_forecasts_json(number_of_scores=nil)
        self.thinkspace_weather_forecaster_forecasts.top_forecasts_json(number_of_scores)
      end

      def forecast_day_class; Thinkspace::WeatherForecaster::ForecastDay; end

      class FindOrCreateError < StandardError; end

      # ###
      # ### Clone Assessment.
      # ###

      include ::Totem::Settings.module.thinkspace.deep_clone_helper

      def cyclone(options={})
        self.transaction do
          clone_associations = [:thinkspace_weather_forecaster_assessment_items]
          cloned_assessment  = clone_self(options, clone_associations)
          clone_save_record(cloned_assessment)
        end
      end

      # ###
      # ### Delete Ownerable Data.
      # ###

      include ::Totem::Settings.module.thinkspace.delete_ownerable_data_helper

      def ownerable_data_associations; [:thinkspace_weather_forecaster_forecasts]; end

    end
  end
end
