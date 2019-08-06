# clear; rake thinkspace:migrate:inspect[../../migrate-ts-1-to-2/assignments] S=lab_charts

module Thinkspace; module Migrate; module Assignments; module Helpers
  class LabChart
    attr_reader :nodes
    attr_reader :categories
    attr_reader :current_node
    attr_reader :current_category
    attr_reader :parse_inst

    def initialize(parse_inst, nodes)
      @nodes      = nodes
      @parse_inst = parse_inst
      @categories = Hash.new
      process_nodes
    end

    def phase_type; parse_inst.get_phase_type; end

    # XML node mappings.
    def type;             get_node_value(:type); end
    def category_title;   get_node_value(:panel); end
    def title;            get_node_value(:name); end
    def description;      get_node_value(:description); end
    def result;           get_node_value(:result); end
    def adjusted_result;  get_node_value(:adjustedResult); end
    def units;            get_node_value(:units); end
    def ratings;          get_node_value(:ratings); end
    def analysis;         get_node_value(:ratings); end
    def abnormality;      get_node_value(:abnormality); end
    def correct_analysis; get_node_value(:correctRating); end
    def normal_analysis;  get_node_value(:normalRating); end
    def lower_bound;      get_node_value(:lowerBound); end
    def upper_bound;      get_node_value(:upperBound); end

    def process_nodes
      nodes.each do |node|
        @current_node = node
        set_current_category
        case type.to_sym
        when :title            # ignore
        when :header           then add_category
        when :result           then add_result
        when :adjustedResult   then add_adjusted_result
        when :observation      then add_observation_result
        else
          raise_error "Unknown lab test type #{type.inspect}."
        end
      end
    end

    # ###
    # ### Category - Type: header.
    # ###

    # Set or initialize the current category.
    def set_current_category
      if categories.has_key?(category_title)
        @current_category = categories[category_title]
        return
      end
      category                        = categories[category_title] = Hash.new
      category[:title]                = category_title
      category[:position]             = get_position
      category[:metadata]             = Hash.new
      category[:results]              = Array.new  # not part of category model; used to build the results for the category
      value                           = category[:value] = Hash.new
      value[:component]               = :vet_med
      value[:columns]                 = Array.new
      value[:messages]                = Hash.new
      value[:correctable_prompt]      = 'Should this be corrected?'
      @current_category               = category
    end

    # Category mapping used in the add result methods.
    def category_results; current_category[:results]; end

    def add_category
      value    = current_category[:value]
      columns  = value[:columns]
      return unless columns.empty?
      columns.push(heading: title,           source: :title)                 if title.present? 
      columns.push(heading: result,          source: :result)                if result.present?
      columns.push(heading: units,           source: :units)                 if units.present?
      columns.push(heading: ratings,         source: :ratings, range: true)  if ratings.present?
      columns.push(heading: 'Analysis',      observation: :analysis)         if analysis.present?
      columns.push(heading: abnormality,     observation: :abnormality)      if abnormality.present?
      add_category_metadata
    end

    # TODO: Is max attempts at the category level (e.g. for all results) or at the individual result?
    def add_category_metadata
      # metadata               = current_category[:metadata]
      # metadata[:analysis]    = get_max_attempts(max: 3, lock: true)
      # metadata[:abnormality] = get_max_attempts(max: 3, lock: true)
    end

    # ###
    # ### Result - Type: result.
    # ###

    def add_result
      hash                       = Hash.new
      metadata                   = hash[:metadata] = Hash.new
      value                      = hash[:value]    = Hash.new
      columns                    = value[:columns] = Hash.new
      observations               = value[:observations] = Hash.new
      hash[:title]               = title
      hash[:position]            = get_position
      value[:type]               = :result
      value[:description]        = description
      columns[:units]            = units
      columns[:result]           = result
      columns[:ratings]          = {lower: lower_bound, upper: upper_bound}
      normal                     = normal_analysis.present? ? label_to_id(normal_analysis) : nil
      observations[:analysis]    = {input_type: :select}.merge(selections: get_selections(analysis), normal: normal)
      observations[:abnormality] = {input_type: :input}
      if analysis.present?
        #
        meta_hash           = Hash.new
        validate            = meta_hash[:validate] = Hash.new
        validate[:correct]  = label_to_id(get_correct_analysis)
        metadata[:analysis] = meta_hash  # add a merge of the max attempts hash if needed
      end
      if abnormality.present?
        meta_hash                = Hash.new
        meta_hash[:max_attempts] = 3
        validate                 = meta_hash[:validate] = Hash.new
        validate[:correct]       = get_correct_input(abnormality)
        metadata[:abnormality]   = meta_hash  # add a merge of the max attempts hash if needed
      end
      category_results.push(hash)
    end

    # ###
    # ### Adjusted Result - Type: adjusted_result.
    # ###

    def add_adjusted_result
      hash                             = Hash.new
      metadata                         = hash[:metadata] = Hash.new
      value                            = hash[:value]    = Hash.new
      columns                          = value[:columns] = Hash.new
      observations                     = value[:observations] = Hash.new
      hash[:title]                     = title
      hash[:position]                  = get_position
      value[:type]                     = :adjusted_result
      value[:description]              = description
      columns[:units]                  = units
      columns[:result]                 = result
      columns[:ratings]                = {lower: lower_bound, upper: upper_bound}
      observations[:analysis]          = {input_type: :correctable}
      observations[:abnormality]       = get_no_input_type
      meta_hash                        = Hash.new
      meta_hash[:max_attempts]         = 3
      meta_hash[:lock_on_max_attempts] = false
      validate                         = meta_hash[:validate] = Hash.new
      validate[:correct_method]        = get_adjust_result_correct_method
      validate[:correct]               = adjusted_result
      metadata[:analysis]              = meta_hash
      metadata[:abnormality]           = get_no_input_value
      category_results.push(hash)
    end

    # ###
    # ### Observation Result - Type: observation_result.
    # ###

    def add_observation_result
      hash                = Hash.new
      metadata            = hash[:metadata] = Hash.new
      value               = hash[:value]    = Hash.new
      columns             = value[:columns] = Hash.new
      observations        = value[:observations] = Hash.new
      hash[:title]        = title
      hash[:position]     = get_position
      value[:type]        = :html_result
      value[:description] = description

      columns[:result]    = get_observation_result_result
      category_results.push(hash)
    end

    def get_observation_result_result
      image_prefix = @parse_inst.image_prefix
      return result unless image_prefix.present?
      image_formats = ['jpg', 'jpeg', 'tiff', 'png', 'gif']
      doc           = ::Nokogiri::HTML.fragment(result)
      anchors       = doc.css('a')
      if anchors.present?
        anchors.each do |anchor|
          href      = anchor.attribute('href').text
          file_name = href.split('/').pop
          extension = file_name.split('.').pop
          return result unless image_formats.include?(extension)
          path                             = image_prefix + "/#{file_name}"
          anchor.attribute('href').value   = path
          anchor.set_attribute('target', '_blank')
        end
      end
      anchors.present? ? doc.to_html : result
    end

    # ###
    # ### Helpers.
    # ###

    def get_no_input_type;  {input_type: :none}; end
    def get_no_input_value; {no_value: true}; end

    def get_max_attempts(options={})
      max  = options[:max]
      lock = options[:lock]
      hash = Hash.new
      hash[:max_attempts]         = max    if max.present?
      hash[:lock_on_max_attempts] = true   if lock == true
      hash
    end

    def get_position
      id = current_node.attribute('_id').text
      raise_error "Lab test id is blank."  if id.blank?
      id.to_i
    end

    def get_adjust_result_correct_method
      :standard_adjusted
    end

    def get_selections(select_string)
      selections     = Array.new
      select_options = select_string.split(',').map {|s| s.strip}
      raise_error "Select options are not a string #{select_string.inspect}."  unless select_string.is_a?(String)
      select_options.each do |label|
        id = label_to_id(label)
        selections.push(id: id, label: label)
      end
      selections
    end

    def get_correct_analysis
      correct = correct_analysis
      return correct if correct.is_a?(String)
      node = current_node.css('ratings')
      node.attribute('correct').text
    end

    def get_correct_input(input); input.split(',').map {|i| i.strip}; end

    def label_to_id(label)
      raise_error "Label is blank."  if label.blank?
      label.underscore.gsub(' ', '_')
    end

    def print_debug(message='')
      parse_inst.print_debug message, ids: true
      parse_inst.print_debug current_node.to_s, nothing: true
    end

    def get_node_value(attribute)
      val = current_node.css(attribute.to_s)
      val.present? ? val.text : nil
    end

    def raise_error(message='')
      message = message + "\n" + current_node.to_s
      parse_inst.present? ? parse_inst.raise_error(message) : raise(XMLError, message)
    end

    class XMLError  < StandardError; end

  end

end; end; end; end
