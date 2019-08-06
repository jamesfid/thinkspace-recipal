module Thinkspace; module Migrate; module DiagnosticPathsToIndentedLists; module Helpers; class PhaseTemplates

  # ###
  # ### List Domain Data (will not be called if passed in options).
  # ###

  def get_list_common_component
    titles     = list_common_component_titles
    components = component_class.where(title: titles)
    raise_error "List common component not found with a title in #{titles}."  if components.blank?
    raise_error "More than one list common component exists.  Cannot determine correct one #{components.inspect}.  Use component:id option."  if components.length > 1
    components.first
  end

  def get_list_phase_template
    name           = 'two_column_indented_list_observation_list_submit'
    phase_template = phase_template_class.find_by(name: name)
    raise_error "List phase template #{name.inspect} not found."  if phase_template.blank?
    phase_template
  end

  def get_expert_list_phase_template
    name = 'one_column_indented_list'
    phase_template = phase_template_class.find_by(name: name)
    raise_error "Expert list phase template #{name.inspect} not found."  if phase_template.blank?
    phase_template
  end

  def get_phase_component_section_in_list_template(list_phase_template)
    titles = list_common_component_titles
    hash   = parse_phase_template(list_phase_template.template).find {|c| titles.include?(c[:title])}
    raise_error "List phase template does not have a common component title of #{common_components}. #{list_phase_template.inspect}"  if hash.blank?
    section = hash[:section]
    raise_error "List phase template section is blank #{hash.inspect}."  if section.blank?
    section
  end

  # ###
  # ### Validate Path Template and List Template are Compatible.
  # ###

  def validate_phase_templates(phase, list_phase_template)
    phase_template = get_phase_template_from_phase(phase)
    template       = parse_phase_template(phase_template.template)
    raise_error "Phase template #{phase_template.id} template content is blank for phase #{phase.inspect}."  if template.blank?
    list_template  = parse_phase_template(list_phase_template.template)
    raise_error "List phase template #{list_phase_template.id} template content is blank."  if list_template.blank?
    validate_templates(template, list_template)
  end

  private

  # ###
  # ### Domain Data (modify to match typical run).
  # ###

  def list_common_component_titles; ['indented-list']; end
  def list_template_sections; list_common_component_titles + ['list']; end

  def diagnostic_path_common_component_titles; ['diagnostic-path']; end
  def diagnostic_path_template_sections; diagnostic_path_common_component_titles + ['diag-path']; end

  # ###
  # ### Helpers.
  # ###

  def component_class;      ::Thinkspace::Common::Component; end
  def phase_template_class; ::Thinkspace::Casespace::PhaseTemplate; end

  def get_phase_template_from_phase(phase)
    phase_template = phase.thinkspace_casespace_phase_template
    raise_error "Phase id #{phase.id} phase template is blank."  if phase_template.blank?
    phase_template
  end

  def parse_phase_template(template)
    array      = Array.new
    html       = Nokogiri::HTML.fragment(template)
    components = html.css('component')
    components.each do |component|
      comp = Hash.from_xml(component.to_s)['component'] || Hash.new
      array.push(comp.symbolize_keys)
    end
    array
  end

  # ###
  # ### Validate Templates.
  # ###

  def validate_templates(template, list_template)
    validate_template_titles(template, list_template)
    validate_template_sections(template, list_template)
    validate_template_sources(template, list_template)
  end

  def validate_template_titles(template, list_template)
    phase_titles = template.collect       {|c| c[:title]}.compact
    list_titles  = list_template.collect  {|c| c[:title]}.compact
    ptitles      = (phase_titles - diagnostic_path_common_component_titles).sort
    ltitles      = (list_titles  - list_common_component_titles).sort
    raise_error "Template titles differ.  Phase template #{ptitles}, List template #{ltitles}."  unless ptitles == ltitles
  end

  def validate_template_sections(template, list_template)
    phase_sections = template.collect       {|c| c[:section] || c[:title]}.compact
    list_sections  = list_template.collect  {|c| c[:section] || c[:title]}.compact
    psections      = (phase_sections - diagnostic_path_template_sections).sort
    lsections      = (list_sections  - list_template_sections).sort
    raise_error "Template sections differ.  Phase template #{psections}, List template #{lsections}."  unless psections == lsections
  end

  def validate_template_sources(template, list_template)
    psources = template.collect       {|c| c[:source]}.compact.sort
    lsources = list_template.collect  {|c| c[:source]}.compact.sort
    raise_error "Template sources differ.  Phase template #{psources}, List template #{lsources}."  unless psources == lsources
  end

  # ###
  # ### Errors.
  # ###

  def raise_error(message='')
    raise PhaseTemplatesError, message
  end

  class PhaseTemplatesError < StandardError; end

end; end; end; end; end
