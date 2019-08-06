class Thinkspace::Seed::Phases < Thinkspace::Seed::BaseHelper

  attr_reader :phase_sections

  def config_keys; [:phases]; end

  def process(*args)
    super
    return unless process?
    process_config
  end

  private

  def process_config
    @phase_sections ||= Hash.new
    array = [config[:phases]].flatten.compact
    return if array.blank?
    space      = nil
    assignment = nil
    template   = nil
    array.each do |hash|
      title = hash[:space]
      if title.present?
        space = find_space(title: title)
        config_error "Phase space #{title.inspect} not found [phase: #{hash.inspect}].", config  if space.blank?
      end
      title = hash[:assignment]
      if title.present?
        assignment = space.blank? ? find_assignment(title: title) : find_assignment(title: title, space: space)
        config_error "Phase assignment #{title.inspect} not found [phase: #{hash.inspect}].", config  if assignment.blank?
      end
      config_error "Phase assignment has not been specified and is not inheritable [phase: #{hash.inspect}].", config  if assignment.blank?
      template_name = hash[:template_name] || hash[:phase_template]
      if template_name.present?
        phase_template = find_phase_template(name: template_name)
        config_error "Phase template name #{template_name.inspect} not found [phase: #{hash.inspect}].", config  if phase_template.blank?
      end
      config_error "Phase template has not be specified and is not inheritable [phase: #{hash.inspect}].", config  if phase_template.blank?
      if (category = hash[:team_category]).present?
        team_category = find_team_category(category: category)
        config_error "Phase team category #{category.inspect} not found [phase: #{hash.inspect}].", config  if team_category.blank?
      else
        team_category = nil
      end
      position = hash[:position] || assignment.thinkspace_casespace_phases.count + 1
      options  = hash.merge(assignment: assignment, phase_template: phase_template, team_category: team_category, position: position, find_or_create: true)
      phase    = find_phase(options)
      add_phase_components(phase, phase_template, options)
      add_config_model(phase)
      phase_sections[phase.id] = options[:sections]
    end
  end

  def add_phase_components(phase, phase_template, options)
    get_ordered_template_section_hash(phase_template).each do |section, attrs|
      title            = attrs['title']
      common_component = find_common_component(title: title)
      config_error "Phase #{phase.title.inspect} phase template #{phase_template.name.inspect} section #{section.inspect} common component #{title.inspect} not found.", config  if common_component.blank?
      phase_component = create_model(:casespace, :phase_component,
        section:        section,
        phase:          phase,
        component:      common_component,
        componentable:  phase_componentable?(common_component) ? phase : nil
      )
    end
  end

  # Check if any seed phase components should be built after other section components in the same phase template.
  # For example, if a section's 'componentable' depends on another section's 'componentable' but is
  # defined before the dependent section in the phase_template.
  def get_ordered_template_section_hash(phase_template)
    do_last        = []  # hard coded list of known components to build last
    component_hash = ActiveSupport::OrderedHash.new
    last_array     = Array.new
    template_hash  = parse_phase_template(phase_template)
    template_hash.each do |section, attrs|
      title = attrs['title']
      config_error "Phase template name #{phase_template.name.inspect} does not have a title.", config  if title.blank?
      do_last.select {|t| title.start_with?(t)}.blank? ? component_hash[section] = attrs : last_array.push([section, attrs])
    end
    last_array.each {|section, attrs| component_hash[section] = attrs}
    component_hash
  end

  def parse_phase_template(template)
    hash       = Hash.new
    html       = Nokogiri::HTML.fragment(template.template)
    components = html.css('component')
    validate_template(template, components)
    components.each do |component|
      comp    = Hash.from_xml(component.to_s)['component'] || Hash.new
      section = comp.delete('section') || comp['title']  # totem-template-manager will default the section to the title
      hash[section] = comp
    end
    hash
  end

  def validate_template(template, components)
    references = Array.new
    sections   = Array.new
    components.each do |component|
      section = component.attributes['section'] || component.attributes['title'] # totem-template-manager will default the section to the title
      config_error "Phase template name #{template.name.inspect} component tag is missing a section attribute [#{component.to_s}].", config  if section.blank?
      section = section.to_s
      config_error "Phase template name #{template.name.inspect} has a duplicate section value #{section.inspect} [#{component.to_s}].", config  if sections.include?(section)
      sections.push(section)
      attributes = component.attributes
      attributes.each do |key, value|
        next if key == 'title'
        next if key == 'section'
        next if key.start_with?('data-')
        if value.present?
          value = value.to_s
          next  if value == 'true' || value == 'false'  # if a boolean, then is not a reference to another section
          values      = value.split(' ').select {|v| v.present?}
          references += values.map {|v| v.strip}
        end
      end
    end
    references  = [references].flatten.compact.uniq
    not_defined = references - sections
    config_error "Phase template name #{template.name.inspect} has undefined references #{not_defined}.", config  if not_defined.present?
  end

end
