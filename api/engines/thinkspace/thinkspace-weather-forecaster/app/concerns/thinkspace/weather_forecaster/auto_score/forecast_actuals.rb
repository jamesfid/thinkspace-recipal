require 'open-uri'

module Thinkspace
  module WeatherForecaster
    module AutoScore

      class ForecastActuals
        
        attr_reader :run_options
        attr_reader :current_station_code
        attr_reader :loaded_actuals

        def initialize(options={})
          @run_options    = options
          @loaded_actuals = Array.new
        end

        def process(forecast_day, station_id)
          raise_error "Forecast day is blank."  if forecast_day.blank?
          raise_error "Station id is blank."    if station_id.blank?
          raise_error "Forecast day should be an instance of forecast day not #{forecast_day.class.name.inspect}." unless forecast_day.is_a?(forecast_day_class)
          reload? ? reload_actuals_from_file(forecast_day, station_id) : get_forecast_day_actuals(forecast_day, station_id)
        end

        private

        def reload_actuals_from_file(forecast_day, station_id)
          has_been_loaded?(forecast_day, station_id) ? get_forecast_day_actuals(forecast_day, station_id) : load_actuals_from_file(forecast_day, station_id)
        end

        def get_forecast_day_actuals(forecast_day, station_id)
          forecast_day_actual = get_forecast_day_actual(forecast_day, station_id)
          forecast_day_actual.present? ? forecast_day_actual : load_actuals_from_url(forecast_day, station_id)
        end

        def load_actuals_from_url(forecast_day, station_id)
          station = station_class.find_by(id: station_id)
          raise_error "Station id #{station_id} not found."  if station.blank?
          url     = get_url_for_forecast_day(forecast_day)
          debug_message "Loading actuals from URL [#{url}] for #{forecast_day.forecast_at.to_date.to_s(:db)} and station #{station.location.inspect}"  if debug? && !has_been_loaded?(forecast_day, station_id)
          begin
            content = open(url).read
          rescue OpenURI::HTTPError => e
            raise_error "The requested URL [#{url}] was not found on the server."
          end
          actuals, original = get_actuals_for_day_and_station(content, forecast_day, station)
          raise_error "Station #{station.location.inspect} id #{station.id} not found in actuals URL [#{url}]"  if actuals.blank?
          update_or_create_forecast_day_actual(forecast_day, station_id, actuals, original)
        end

        def load_actuals_from_file(forecast_day, station_id)
          station = station_class.find_by(id: station_id)
          raise_error "Station id #{station_id} not found."  if station.blank?
          file_path = get_file_path_for_forecast_day(forecast_day)
          raise_error   "File at path #{file_path.inspect} not found."  unless File.file?(file_path)
          debug_message "Loading actuals from file #{file_path.inspect} for #{forecast_day.forecast_at.to_date.to_s(:db)} and station #{station.location.inspect}"  if debug? && !has_been_loaded?(forecast_day, station_id)
          actuals, original = get_actuals_for_day_and_station(File.read(file_path), forecast_day, station)
          raise_error "Station #{station.location.inspect} id #{station.id} not found in actuals file #{file_path.inspect}."  if actuals.blank?
          update_or_create_forecast_day_actual(forecast_day, station_id, actuals, original)
        end

        def get_file_path_for_forecast_day(forecast_day)
          # TODO: need to determine how and where to get this information

          # ### TESTING ONLY ###
          filename  = 'test_file_'
          filename += (forecast_day.id % 3).to_s
          filename += '.txt'
          File.join(Rails.root, "../../forecasting/#{filename}")
          # ### TESTING ONLY ###

        end

        def get_url_for_forecast_day(forecast_day)
          forecast_at = forecast_day.forecast_at
          raise_error "Forecast day [#{forecast_day.id}] does not have a forecast_at." unless forecast_at.present?
          date     = forecast_at.strftime('%Y%m%d')
          base_url = 'http://meteor.geol.iastate.edu/fcst/'
          url      = base_url + date + '.out'
          debug_message "Found URL for date as: #{url}" if debug?
          url
        end

        def update_or_create_forecast_day_actual(forecast_day, station_id, actuals, original)
          forecast_day_actual = get_forecast_day_actual(forecast_day, station_id)
          if forecast_day_actual.blank?
            forecast_day_actual = forecast_day_actual_class.get_new_record(forecast_day.id, station_id)
          end
          forecast_day_actual.value    = actuals
          forecast_day_actual.original = original
          return forecast_day_actual  if dry_run?
          raise_error "Could not save forecast day actual #{forecast_day_actual.inspect}."  unless forecast_day_actual.save
          forecast_day_actual
        end

        def has_been_loaded?(forecast_day, station_id)
          loaded = [forecast_day.id, station_id]
          if loaded_actuals.include?(loaded)
            true
          else
            loaded_actuals.push(loaded)
            false
          end
        end

        # ###
        # ### Read and Parse Actuals File.
        # ###

        def get_actuals_for_day_and_station(content, forecast_day, station)
          @current_station_code = station.location.downcase
          original              = ''
          collect               = false
          content.each_line do |line|
            if line.strip.match(/^station=/i)
              station, code = line.chomp.split('=',2)
              collect       = (code.downcase == current_station_code)
              original     += line if collect
            else
              if collect
                original += line
              else
                break  if original.present?
              end
            end
          end
          raise_code_error "did not have values in content."  if original.blank?
          [convert_station_code_values(original), original]
        end

        def convert_station_code_values(original)
          actuals = Hash.new
          original.each_line do |oline|
            line = oline.chomp.strip
            next if line.match(/^station=/i)
            var, value = line.split('=',2)
            var   = var.strip   if var.present?
            value = value.strip if value.present?
            raise_code_error "has an invalid 'variable=value' format #{line.inspect}."  unless var.present? && value.present?
            raise_code_error "has duplicate variable #{var.inspect}."  if actuals.has_key?(var)
            actuals[var] = parse_variable_value(value)
          end
          actuals
        end

        def parse_variable_value(value)
          error_message = "has an invalid variable range format #{value.inspect}."
          logic         = nil
          actual        = nil
          case
          when is_integer?(value)
            logic  = :equal
            actual = value
          when value.match(',')
            logic  = :and
            actual = value.split(',').map {|v| v.strip}
            raise_code_error error_message  if actual.find {|v| v.blank?}
          when value.match(':')
            logic    = :range
            min, max = value.split(':').map {|v| v.strip}
            raise_code_error error_message  if min.blank? || max.blank?
            raise_code_error error_message + "  Minimum value not an integer."  unless is_integer?(min)
            raise_code_error error_message + "  Maximum value not an integer."  unless is_integer?(max)
            raise_code_error error_message + "  Mimimum value greater then maximum value."  if min.to_i > max.to_i
            actual = {min: min, max: max}
          when value.match('|')
            logic  = :or
            actual = value.split('|').map {|v| v.strip}
            raise_code_error error_message  if actual.find {|v| v.blank?}
          end
          raise_code_error error_message  if logic.blank? || actual.blank?
          {logic: logic, actual: actual}
        end

        # ###
        # ### Helpers.
        # ###

        def get_forecast_day_actual(forecast_day, station_id)
          forecast_day_actual_class.scope_by_forecast_day_id_and_station_id(forecast_day.id, station_id)
        end

        def is_integer?(value)
          return false if value.blank?
          value.to_s.match(/^[-|+]?\d+$/)
        end

        def reload?;    run_options[:reload_actuals].present?; end
        def dry_run?;   run_options[:dry_run].present?; end
        def debug?;     run_options[:debug].present?; end
        def quiet?;     run_options[:quiet].present?; end

        def station_class;             Thinkspace::WeatherForecaster::Station; end
        def forecast_day_class;        Thinkspace::WeatherForecaster::ForecastDay; end
        def forecast_day_actual_class; Thinkspace::WeatherForecaster::ForecastDayActual; end

        def debug_message(message='')
          puts message
        end

        # ###
        # ### Raise Errors.
        # ###
        # AutoScore::Process rescues from specific error classes.  Raise them if passed in the initialize options.

        def raise_code_error(message='')
          raise_error "Station code #{current_station_code.inspect} " + message
        end

        def raise_non_fatal_error(message='')
          error_class = run_options[:non_fatal_error_class] || run_options[:error_class] || ProcessError
          raise error_class, message
        end

        def raise_error(message='')
          error_class = run_options[:error_class] || ProcessError
          raise error_class, message
        end

        class ProcessError < StandardError; end

      end
    end
  end
end
