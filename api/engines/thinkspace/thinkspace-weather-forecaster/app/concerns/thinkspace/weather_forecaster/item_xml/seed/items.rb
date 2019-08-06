require 'nokogiri'
module Thinkspace
  module WeatherForecaster
    module ItemXml
      module Seed
        class Items < Base

          def extract_items(args=nil)
            extract_items_from_xml(args)
          end

          private

          def extract_items_from_xml(args)
            set_item_root_path(args)
            parser_filename = get_parser_filename
            parser_path     = File.join(root_path, parser_filename)
            dirs            = File.file?(parser_path) ? [root_path] : get_all_item_xml_paths(root_path)
            validate_xml_parsers_exist(dirs, parser_filename)
            validate_xml_files_exist(dirs)
            items = get_items_in_xml_files(dirs, parser_filename)
            stop_run "No items extracted from xml in directories #{dirs}."  if items.blank?
            model_attributes = get_item_model_attributes(items)
            stop_run "No model attributes generated from xml item directories #{dirs}."  if model_attributes.blank?
            model_attributes_to_yaml(model_attributes)
          end

          def set_item_root_path(args)
            args = [args].flatten.compact
            args = 'item_xml'  if args.blank?
            set_root_path(args)
          end

          def get_items_in_xml_files(dirs, parser_filename)
            items = Array.new
            [dirs].flatten.compact.each do |dir|
              items.push parse_xml_items_in_directory(dir, parser_filename)
            end
            items
          end

          def parse_xml_items_in_directory(dir, parser_filename)
            items     = Array.new
            xml_files = get_directory_xml_files(dir)
            xml_files.each do |file|
              xml    = File.read(file)
              parser = new_xml_item_parser(dir, parser_filename)
              parser.process(xml)
              items.push parser.parser_items
            end
            items
          end

          def get_item_model_attributes(items)
            converter  = new_xml_item_converter
            attributes = Array.new
            [items].flatten.compact.each do |item|
              attributes.push converter.model_attributes(item)
            end
            attributes
          end

          def validate_xml_parsers_exist(dirs, parser_filename)
            [dirs].flatten.compact.each do |dir|
              parser = File.join(dir, parser_filename)
              stop_run "XML parser #{parser_filename.inspect} not found in #{dir.inspect}."  unless File.file?(parser)
            end
          end

          def validate_xml_files_exist(dirs)
            files = dirs.map {|dir| get_directory_xml_files(dir)}.flatten.compact
            stop_run "No XML files found in #{root_path.inspect}."  if files.blank?
          end

          def get_all_item_xml_paths(dir); Dir.glob(File.join(dir, '*')).select {|d| File.directory?(d)}; end

          def get_directory_xml_files(dir); Dir.glob File.join(dir, 'xml_files', '**/*.xml'); end

          def new_xml_item_parser(dir, parser_filename); Parser.new(dir, parser_filename); end

          def new_xml_item_converter; Converter.new; end

          def get_parser_filename
            env_parser = ENV['P'] || ENV['PARSER'] || 'parser.rb'
            env_parser += '.rb'  unless env_parser.end_with?('.rb')
            env_parser
          end

        end
      end
    end
  end
end
