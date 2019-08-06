module Thinkspace
  module WeatherForecaster
    class ForecastDay < ActiveRecord::Base        
      totem_associations

      validates :forecast_at, presence: true, uniqueness: true

      STATE_DEFAULT  = 'unlocked'
      STATE_UNLOCKED = 'unlocked'
      STATE_LOCKED   = 'locked'

      # ###
      # ### Scopes.
      # ###

      def self.scope_between_days(start_day, end_day); where(forecast_at: (start_day..end_day)); end
      def self.scope_by_days(days); where(forecast_at: days); end

      def self.find_day (day);   find_by(forecast_at: day); end
      def self.find_current_day; find_day(get_current_day); end

      def self.previous_forecast_days(number_of_days=1)
        current_day = get_current_day
        scope_between_days(current_day - number_of_days.days, current_day - 1.day)
      end

      def self.find_or_create_current_forecast_day; find_or_create_forecast_day(get_current_day); end

      def self.find_or_create_forecast_day(time)
        day          = get_day(time)
        forecast_day = find_day(day)
        if forecast_day.present?
          if !forecast_day.locked? && lock_day?(day)
            forecast_day.state = STATE_LOCKED
            raise FindOrCreateError, "Error saving locked forecast day [errors: #{forecast_day.errors.messages}] [date: #{day}]."  unless forecast_day.save
          end
        else
          state = lock_day?(day) ? STATE_LOCKED : STATE_DEFAULT
          forecast_day = self.create(forecast_at: day, state: state)
          raise FindOrCreateError, "Could not find or create forecast day [errors: #{forecast_day.errors.messages}] [date: #{day}]."  if forecast_day.errors.present?
        end
        raise FindOrCreateError, "Could not find or create forecast day [date: #{day}]."  if forecast_day.blank?
        forecast_day
      end

      def self.get_current_day; get_day(Time.now.in_time_zone('America/Chicago')); end
      def self.get_day(time)
        parsed = time.strftime('%Y-%m-%d')
        time   = Time.parse(parsed)
        time.utc.end_of_day
      end

      def self.lock_day?(day); day + 1.second < get_current_day; end  # add 1 second since the record's datetime has less precision than a Time object

      # ###
      # ### Instance Methods.
      # ###

      # 'locked?'    means the forecast_day.state == 'locked'.
      # 'is_locked?' means the forecast_day has a locked state OR is locked due to the forecast date
      #              being in the past e.g. the auto-score job has not yet been run to lock it.
      #              Code (other than this model) should use 'is_locked?'.
      def locked?;      self.state == STATE_LOCKED; end
      def set_locked;   self.state = STATE_LOCKED; end
      def is_locked?;   locked? || self.class.lock_day?(self.forecast_at); end
      def is_unlocked?; !is_locked?; end

      def default_state; STATE_DEFAULT; end

      class FindOrCreateError < StandardError; end

    end
  end
end