module Thinkspace
  module WeatherForecaster
    module ItemXml
      module Seed
        class Base

          attr_reader :totem_settings
          attr_reader :engine
          attr_reader :root_db_path
          attr_reader :root_path

          def initialize(env=nil)
            @totem_settings = env || ::Totem::Settings
            set_engine
            set_root_db_path
          end

          private

          def set_engine
            engine_name = 'thinkspace_weather_forecaster'
            engines     = totem_settings.engine.get_by_name(engine_name)
            stop_run "Could not find engine #{engine_name.inspect}."      if engines.blank?
            stop_run "Mutiple engines found for #{engine_name.inspect}."  if engines.length > 1
            @engine = engines.first
          end

          def set_root_db_path; @root_db_path = File.join(engine.root, 'db', 'production_data'); end

          def set_root_path(args); @root_path = File.join(root_db_path, args); end

          def model_attributes_to_yaml(model_attributes)
            model_attributes.map {|attrs| attrs.deep_stringify_keys}.to_yaml
          end

          def print_message(message='')
            puts '[wf-seed] ' + message
          end

          def stop_run(message='')
            print_message "\n"
            print_message message
            print_message "Run stopped."
            print_message "\n"
            exit
          end

          def raise_error(message='')
            raise SeedError, message
          end

          class SeedError  < StandardError; end

        end
      end
    end
  end
end
