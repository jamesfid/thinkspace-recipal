require File.expand_path('../../helpers/require_all', __FILE__)
module Thinkspace; module Migrate; module Assignments; module Inspect
  module NodeValuesHelper

    def collect_node_values(node, options={})
      only   = [options[:only]].flatten.compact.map{|v| v.to_s}
      except = [options[:except]].flatten.compact.map{|v| v.to_s} + ['_id']  if only.blank?
      if @collected_values_count.blank?
        @collected_values_count = 0
        @collected_values       = Hash.new
      end
      hash     = Hash.from_xml(node.to_s)
      root_key = hash.keys.uniq.first
      hash[root_key].each do |k, v|
        next if only.present? && !only.include?(k)
        next if except.include?(k)
        @collected_values[k] ||= Array.new
        @collected_values[k].push(v.nil? ? 'nil' : v)
      end
      @collected_values_count += 1
    end

    def print_collected_node_values(*args)
      options     = args.extract_options!
      count_title = args.shift || 'Count'
      only        = [options[:only]].flatten.compact.map{|v| v.to_s}
      except      = [options[:except]].flatten.compact.map{|v| v.to_s} if only.blank?
      case
      when only.present?
        keys = only.sort
      when except.present?
        keys = @collected_values.keys.sort - except
      else
        keys = @collected_values.keys.sort
      end
      keys.each_with_index do |key, index|
        array = (@collected_values || Hash.new)[key] || Array.new
        puts "\n"
        puts "#{(index+1).to_s.rjust(4)}. #{key.inspect} ".ljust(80, '-')
        uvs = array.uniq.sort
        len = uvs.map{|uv| uv.present? ? uv.length : 0}.max || 0
        len += 2   if len > 0
        len = 120  if len > 120
        uvs.each_with_index do |uv, i|
          puv = uv.inspect.ljust(len)
          puts "     #{(i+1).to_s.rjust(4)}. #{puv} (count: #{array.count(uv)})"
        end
      end
      puts "\n"
      puts "#{count_title}: #{@collected_values_count}"
      puts "\n"
    end

  end

end; end; end; end
