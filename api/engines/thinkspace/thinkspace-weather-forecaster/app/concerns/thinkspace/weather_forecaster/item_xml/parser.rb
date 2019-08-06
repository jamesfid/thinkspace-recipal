module Thinkspace
  module WeatherForecaster
    module ItemXml

      class Parser

        attr_reader   :parser_items
        attr_accessor :default_id_key

        def initialize(dir=nil, parser_filename=nil)
          parser_extend(dir, parser_filename)  if dir.present?
          @parser_items = Array.new
        end

        def parser_extend(dir, parser_filename)
          parser_filename  = 'parser.rb'  if parser_filename.blank?
          parser_filename += '.rb'  unless File.extname(parser_filename) == '.rb'
          xml_parser       = Dir.glob(File.join(dir, parser_filename)).first
          raise ParserError, "XML Parser not found: #{xml_parser.inspect}.  Did you specify the correct directory and parser filename (defalut 'parser.rb')?"  if xml_parser.blank?
          rc = load xml_parser
          raise ParserError, "XML Parser require failed for #{xml_parser.inspect}."  if rc.blank?
          ns       = File.basename(dir)
          mod_name = "#{self.class.name.deconstantize}::#{ns.classify}"
          mod      = mod_name.safe_constantize
          raise ParserError, "Could not constantize module #{mod_name.inspect}."  if mod.blank?
          extend mod
        end

        def parse_xml(xml)
          Nokogiri.XML(xml) do |config|
            config.nonet
          end
        end

        def parse_html(content)
          Nokogiri::HTML.fragment(content) do |config|
            config.nonet
          end
        end

        def new_item; ItemXml::Item.new; end

        def set_default_id_key(key); @default_id_key = key; end

        def get_attr(node, attribute, default='')
          value = node.attribute(attribute.to_s)
          value.present? ? value.text : default
        end

        def get_id(node, key=default_id_key)
          raise XMLError, "Missing id key #{key.inspect} for node #{node.name.inspect} \n#{node.to_xml}" unless node.key?(key)
          node.attribute(key).text
        end

        def get_id_from_qid(qid)
          raise XMLError, "QUE id is blank." unless qid.present?
          qid.to_s.split('_').last.sub(/\D*/,'')
        end

        def extract_content_and_name_text(content, names, join_with='')
          names = [names].flatten.compact
          html  = parse_html(content)
          nodes = html.css('*').select {|node| names.include?(node.name)}
          text  = nodes.collect {|node| node.to_s}.join(join_with)
          nodes.each {|node| node.remove}
          [html.to_s, text]
        end

        def get_node_attributes_hash(node)
          hash         = Hash.new
          hash['name'] = node.name
          hash['text'] = node.text
          node.attributes.each do |key, value|
            hash[key] = value.to_s
          end
          hash
        end

        def is_integer?(value)
          return false if value.blank?
          value.to_s.match(/^[-|+]?\d+$/)
        end

        def sanitize_string(string)
          string.gsub(/\t/, '').gsub(/\n/, '')
        end

        def print_items(items=parser_items)
          items.each do |item|
            len = 15
            puts "\n" + ('-' * 50) + "\n"
            puts 'id'.ljust(len) + ': ' + item.id
            puts 'title'.ljust(len) + ': ' + item.title
            puts 'content'.ljust(len) + ': ' + item.content
            if (response = item.response).present?
              puts 'response id'.ljust(len) + ': ' + response.id
              response.response.choices.each do |choice|
                puts '  - choice id'.ljust(len) + ': ' + choice.id
              end
            end
            conditions = item.processing.condition
            conditions.each do |key, condition|
              # puts "#{key}".ljust(len) + ': ' + condition.id
              if (ret = condition.ret).present?
                [ret].flatten.compact.each do |r|
                  puts "  - #{key} ret".ljust(len) + ': ' + r
                end
              end
            end
          end
        end

        class XMLError    < StandardError; end
        class ParserError < StandardError; end

      end

    end
  end
end
