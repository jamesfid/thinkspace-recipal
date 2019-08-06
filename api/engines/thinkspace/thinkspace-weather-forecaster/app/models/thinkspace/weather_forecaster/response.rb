module Thinkspace
  module WeatherForecaster
    class Response < ActiveRecord::Base        
      def response_score_metadata; get_response_score_metadata; end
      totem_associations
      has_paper_trail

      validates_presence_of :thinkspace_weather_forecaster_forecast, :thinkspace_weather_forecaster_assessment_item

      # ###
      # ### Scopes.
      # ###

      def self.sum_response_scores
        joins(:thinkspace_weather_forecaster_response_score).
        sum(:score)
      end

      # ###
      # ### Instance Methods.
      # ###

      def get_input_value; (self.value || Hash.new)['input']; end

      def find_or_create_response_score
        response_score = self.thinkspace_weather_forecaster_response_score
        if response_score.blank?
          response_score = create_thinkspace_weather_forecaster_response_score
          raise FindOrCreateError, "Could not find or create response score for response [errors: #{response_score.errors.messages}] [#{self.inspect}]."  if response_score.errors.present?
        end
        raise FindOrCreateError, "Could not find or create response score for response [#{self.inspect}]."  if response_score.blank?
        response_score
      end

      class FindOrCreateError < StandardError; end

      # ###
      # ### Score.
      # ###

      def get_response_score_metadata(options={})
        response_score = self.thinkspace_weather_forecaster_response_score
        return nil if response_score.blank?
        add_response_score_values(options)
        options[:score] = response_score.score
        options.slice(:is_correct, :var_actual, :score)
      end

      def calculate_score(options={})
        add_response_score_values(options)
        add_processing(options)
        processing = options[:processing]   || Hash.new
        incorrect  = processing[:incorrect] || 0
        correct    = processing[:correct]   || 0
        score      = options[:is_correct].present? ? correct : incorrect
        debug_message(options.merge(score: score))  if debug?(options)
        score
      end

      # ###
      # ### Score Helpers.
      # ###

      def add_response_score_values(options={})
        item                = add_item(options)
        forecast_day_actual = add_forecast_day_actual(options)
        return options if forecast_day_actual.blank? || item.blank?
        options.merge!(forecast_day_actual.check_response(item.score_var, get_input_value))
      end

      def add_item(options={});            (options[:item]            ||= self.thinkspace_weather_forecaster_item); end
      def add_assessment_item(options={}); (options[:assessment_item] ||= self.thinkspace_weather_forecaster_assessment_item); end
      def add_forecast(options={});        (options[:forecast]        ||= self.thinkspace_weather_forecaster_forecast); end
      def add_score_var(options={});       (options[:score_var]       ||= add_item(options).score_var); end

      def add_forecast_day_actual(options={})
        options[:forecast_day_actual] ||= begin
          forecast = add_forecast(options)
          forecast_day_actual_class.scope_by_forecast(forecast)
        end
      end

      def add_processing(options={})
        item                 = add_item(options)
        assessment_item      = add_assessment_item(options)
        processing           = (item.processing || Hash.new).deep_symbolize_keys
        options[:processing] = processing.deep_merge((assessment_item.processing || Hash.new).deep_symbolize_keys)
      end

      def debug?(options); options[:debug].present?; end

      def debug_message(options={})
        len      = 20
        forecast = add_forecast(options)
        puts "response.id: #{self.id} " + ('-' * 80)
        puts '   ownerable'.ljust(len)    + ": #{forecast.ownerable_type}.#{forecast.ownerable_id} -> #{forecast.ownerable.title.inspect}"
        puts '   forecast at'.ljust(len) + ": #{forecast.forecast_at.to_s(:db)}"
        keys = options.keys.sort
        keys.each do |key|
          value = options[key]
          puts "   #{key}".ljust(len) + ": #{value.inspect}"
        end
      end

      def forecast_day_actual_class; Thinkspace::WeatherForecaster::ForecastDayActual; end

    end
  end
end
