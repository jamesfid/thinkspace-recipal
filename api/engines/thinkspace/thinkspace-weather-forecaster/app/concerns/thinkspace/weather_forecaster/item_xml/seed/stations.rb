require 'csv'
module Thinkspace
  module WeatherForecaster
    module ItemXml
      module Seed
        class Stations < Base

          attr_reader :station_model_columns

          def extract_stations(args=nil)
            extract_stations_from_csv(args)
          end

          private

          def extract_stations_from_csv(args)
            set_station_root_path(args)
            config_files = get_station_config_files
            stop_run "No #{get_station_config_filename.inspect} files found in #{root_path.inspect}."  if config_files.blank?
            configs = get_configs(config_files)
            set_station_model_columns
            all_stations     = get_all_stations
            model_attributes = Array.new
            configs.each do |config|
              station_model_attributes = get_station_model_attributes(all_stations, config)
              model_attributes        += station_model_attributes
              puts "Config #{config[:filename].inspect} station count: #{station_model_attributes.length}"
            end
            model_attributes_to_yaml(model_attributes)
          end

          def set_station_root_path(args)
            args = [args].flatten.compact
            args = 'station_files'  if args.blank?
            set_root_path(args)
          end

          def get_station_config_files
            filename = get_station_config_filename
            stop_run "Station config file(s) path is not a directory #{root_path.inspect}"  unless File.directory?(root_path)
            Dir.chdir(root_path) do
              Dir.glob "**/#{filename}"
            end
          end

          def get_configs(config_files)
            configs = Array.new
            config_files.each do |file|
              file_path = File.join(root_path, file)
              content   = File.read(file_path)
              config    = YAML.load(content)
              stop_run "Config file #{file_path.inspect} is not a hash."  unless config.is_a?(Hash)
              config.deep_symbolize_keys!
              stop_run "Config file #{file_path.inspect} does not have a stations key."  unless config.has_key?(:stations)
              stop_run "Config file #{file_path.inspect} stations key is not an array."  unless config[:stations].is_a?(Array)
              config[:source]     = 'unknown'  unless config.has_key?(:source)
              config[:load_order] = 9999       unless config.has_key?(:load_order)
              config[:file_path]  = file_path
              config[:filename]   = file
              validate_station_config(config)
              configs.push(config)
            end
            configs.sort_by {|h| h[:load_order]}
          end

          def validate_station_config(config)
            stations      = config[:stations]
            uniq_stations = stations.uniq
            unless stations.length == uniq_stations.length
              dup_stations = Array.new
              uniq_stations.each {|code| dup_stations.push(code)  if stations.count(code) > 1}
              stop_run "Duplicate stations #{dup_stations} in config file #{config[:file_path].inspect}."  if dup_stations.present?
            end
          end

          def get_station_model_attributes(all_stations, config)
            source     = config[:source]
            stations   = config[:stations]
            attributes = Array.new
            stations.each do |code|
              hash = all_stations[code]
              stop_run "Invalid station code #{code.inspect} in file #{config[:file_path].inspect}."  if hash.blank?
              attributes.push station_model_attributes(hash).merge(source: source)
            end
            attributes
          end

          def station_model_attributes(hash)
            hash.slice(*station_model_columns)
          end

          def set_station_model_columns
            columns = Thinkspace::WeatherForecaster::Station.column_names - ['id', 'source', 'created_at', 'updated_at']
            @station_model_columns = columns.map {|c| c.to_sym}
          end

          def get_all_stations
            unknown_columns = station_model_columns - get_csv_station_keys
            stop_run "Station model columns #{unknown_columns} not in CSV file."  if unknown_columns.present?
            filename  = 'all_stations.csv'
            file_path = File.join(root_path, filename)
            stop_run "All stations file #{filename.inspect} does not exist in path #{file_path.inspect}."  unless File.file?(file_path)
            all_stations = Hash.new
            options      = {col_sep: ';'}
            CSV.foreach(file_path, options) do |array|
              hash = csv_station_to_hash(array)
              code = hash[:location]
              stop_run "All stations code #{code.inspect} is a duplicate."  if all_stations.has_key?(code)
              all_stations[code] = hash
            end
            all_stations
          end

          def csv_station_to_hash(array)
            keys = get_csv_station_keys
            hash = Hash.new
            keys.each_with_index do |key, index|
              hash[key] = (array[index] || '').strip
            end
            hash
          end

          # Assumes ASCII download with location (e.g. code) in the first column.
          def get_csv_station_keys
            @cvs_station_keys ||= [:location, :block_number, :station_number, :place, :state, :country, :region, :latitude, :longitude, :upper_air_latitude, :upper_air_longitude, :elevation, :upper_air_elevation, :rsbn]
          end

          def get_station_config_filename
            env_filename  = ENV['C'] || ENV['CONFIG'] || 'config.yml'
            env_filename += '.yml'  unless env_filename.end_with?('.yml')
            env_filename
          end

        end
      end
    end
  end
end
