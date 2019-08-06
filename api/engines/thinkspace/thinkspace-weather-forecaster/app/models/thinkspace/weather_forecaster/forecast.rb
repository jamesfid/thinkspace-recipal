module Thinkspace
  module WeatherForecaster
    class Forecast < ActiveRecord::Base
      def is_locked;   is_locked?; end     
      def forecast_at; self.thinkspace_weather_forecaster_forecast_day.forecast_at; end     
      totem_associations
      has_paper_trail

      validates_presence_of :thinkspace_weather_forecaster_forecast_day, :thinkspace_weather_forecaster_assessment, :ownerable

      STATE_UNLOCKED  = 'unlocked'
      STATE_COMPLETED = 'completed'
      STATE_LOCKED    = 'locked'

      # ###
      # ### Scopes.
      # ###

      def self.find_ownerable_day(ownerable, day); scope_by_days(day).find_by(ownerable: ownerable); end

      def self.find_ownerable_current_day(ownerable); find_ownerable_day(ownerable, forecast_day_class.get_current_day); end

      def self.scope_by_days(days)
        joins(:thinkspace_weather_forecaster_forecast_day).
        where(thinkspace_weather_forecaster_forecast_days: {forecast_at: days})
      end

      def self.scope_by_ownerable(ownerable); where(ownerable: ownerable); end

      def self.scope_by_previous_forecast_days
        current_day = forecast_day_class.get_current_day
        joins(:thinkspace_weather_forecaster_forecast_day).
        where('thinkspace_weather_forecaster_forecast_days.forecast_at < ?', current_day)
      end

      def self.scope_and_order_by_previous_forecast_days(by_order='DESC')
        scope_by_previous_forecast_days.
        order("thinkspace_weather_forecaster_forecast_days.forecast_at #{by_order}")
      end

      def self.scope_by_response_ids(ids)
        joins(:thinkspace_weather_forecaster_responses).
        where(thinkspace_weather_forecaster_responses: {id: ids})
      end

      def self.scope_by_state_attempts
        where(state: [STATE_COMPLETED, STATE_LOCKED])
      end

      def self.to_score
        scope_by_previous_forecast_days.
        where(state: [STATE_COMPLETED])
      end

      def self.to_rescore
        scope_by_previous_forecast_days.
        scope_by_state_attempts
      end

      def self.top_forecasts
        select("sum(score) as total_score, ownerable_id, ownerable_type").
        group(:ownerable_id, :ownerable_type).
        order('total_score desc')
      end

      def self.top_forecasts_json(number_of_scores=nil)
        forecasts = number_of_scores.blank? ? top_forecasts : top_forecasts.limit(number_of_scores)
        convert_top_forecast_ownerables(forecasts)
      end

      def self.convert_top_forecast_ownerables(top_forecasts)
        ownerable_classes = Hash.new
        array             = Array.new
        top_forecasts.each do |top_forecast|
          ownerable_type = top_forecast.ownerable_type
          ownerable_id   = top_forecast.ownerable_id
          klass          = (ownerable_classes[ownerable_type] ||= ownerable_type.safe_constantize)
          ownerable      = klass.find(ownerable_id)
          array.push(
            title: ownerable.title,
            score: top_forecast.total_score,
          )
        end
        array
      end

      def self.forecast_day_class;        Thinkspace::WeatherForecaster::ForecastDay; end

      # ###
      # ### Instance Methods.
      # ###

      # Forecast states: 
      #  1. 'unlocked':  Forecast created but not yet submitted.
      #:                 Individual responses may be created for the forecast without submitting it.
      #  2. 'completed': Forecast was submitted but not yet auto-graded.
      #:                 The forecast may also be 'locked' due to the forecast day being locked.
      #  3. 'locked':    Forecast was auto-graded.

      # A forecast may be locked two ways:
      #  1. forecast.state == 'locked'
      #  2. forecast.thinkspace_weather_forecaster_forecast_day == 'locked'
      def is_locked?
        return true if self.state == STATE_LOCKED
        forecast_day = self.thinkspace_weather_forecaster_forecast_day
        forecast_day.blank? ? true : forecast_day.is_locked?
      end

      def is_unlocked?; !is_locked?; end

      def set_completed; self.state = STATE_COMPLETED; end
      def set_locked;    self.state = STATE_LOCKED; end

      def sum_response_scores; self.thinkspace_weather_forecaster_responses.sum_response_scores; end

      def has_all_responses?
        self.thinkspace_weather_forecaster_assessment_items.count == self.thinkspace_weather_forecaster_responses.count
      end

    end
  end
end
