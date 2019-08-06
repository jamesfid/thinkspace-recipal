class Thinkspace::Seed::Html < Thinkspace::Seed::BaseHelper

  # TODO: Common component should not need the 'preprocessors' section and could be removed.

  def common_component_titles; [:html]; end

  def process(*args)
    super
    process_config
    process_auto_input if auto_input?
  end

  private

  def process_config
    @elements = Array.new
    @contents = Array.new
    phase_components = phase_components_by_config
    phase_components.each do |phase_component|
      phase            = @seed.get_association(phase_component, :casespace, :phase)
      common_component = @seed.get_association(phase_component, :common, :component)
      section_hash     = phase_section_value(phase_component) || {}
      options = {
        phase:            phase,
        common_component: common_component,
        section:          phase_component.section,
        description:      common_component.title,
        section_hash:     section_hash,
      }
      html_content = get_sample_content(section_hash, options)
      content      = create_model(:html, :content, authable: phase, html_content: html_content)
      save_phase_component(phase_component, content)
      @contents.push(content)
      create_input_elements(content)
    end
  end

  def get_sample_content(section_hash, options)
    samples          = ::Thinkspace::Seed::HtmlSamples.new(self, @seed, options)
    content          = ''
    section_content  = section_hash[:content]
    content         += samples.row_wrap(section_content) if section_content.present?
    methods          = section_hash[:methods]
    case
    when methods.present?
      content += samples.html_methods(methods)
    else
      content += '<h1>No HTML Content.</h1>' unless section_hash.has_key?(:content)
    end
    content
  end

  def create_input_elements(content)
    input_element_names(content.html_content).each do |hash|
      element = create_model(:input_element, :element, componentable: content, name: hash[:name], element_type: hash[:element_type])
      @elements.push(element)
    end
  end

  def input_element_names(content)
    input_names = []
    radio_names = []
    html        = Nokogiri::HTML.fragment(content)
    inputs      = html.css('input')
    inputs.each do |input|
      type = input['type']
      name = input['name']
      if type == 'radio'
        next if radio_names.include?(name) # radio will have dup names (only add first one)
        radio_names.push(name)
      end
      input_names.push({name: name, element_type: type})
    end
    inputs      = html.css('textarea')
    inputs.each do |input|
      input_names.push({name: input['name'], element_type: 'textarea'})
    end
    input_names
  end

  # ###
  # ### Auto Input.
  # ###

  def process_auto_input
    return if @elements.blank?
    array = auto_input[:responses]
    return if array.blank?
    array.each do |options|
      AutoInput.new(@seed, @configs).process(config, @contents, @elements, options)
    end
  end

  class AutoInput < ::Thinkspace::Seed::BaseHelper
    include ::Thinkspace::Seed::AutoInput

    def process(config, contents, elements, options)
      @config   = config
      @elements = elements
      @contents = contents # currently not used
      set_options(options)
      add_responses
    end

    def set_options(options)
      super
      @roles = [options[:roles]].flatten.compact
    end

    def add_responses
      @elements.each do |element|
        next unless (element.element_type == 'text' || element.element_type == 'textarea')
        phase = element.authable
        next if skip_phase?(phase)
        ownerables = find_phase_ownerables(phase)
        ownerables.each do |ownerable|
          next if skip_ownerable?(ownerable)
          user_id = team?(ownerable) ? 1 : ownerable.id
          value   = response_value(phase, ownerable, element)
          create_model(:input_element, :response, element: element, ownerable: ownerable, user_id: user_id, value: value)
        end
      end
    end

    def response_value(phase, ownerable, element)
      text  = ''
      text += "Element.#{element.id} "
      text += "#{ownerable_text(ownerable)}.#{ownerable.id} "
      text += "Phase.#{phase.id}[#{phase.title}]"
      text
    end

  end # AutoInput

end
