class Thinkspace::Seed::ReadinessAssurance < Thinkspace::Seed::BaseHelper

  def config_keys;             [:readiness_assurance]; end
  def common_component_titles; [:readiness_assurance]; end

  def process(*args)
    super
    return unless process?
    process_config
  end

  private

  def process_config
    array = [config.dig(:readiness_assurance, :assessments)].flatten.compact
    return if array.blank?
    array.each do |hash|
      titles           = hash[:phases]
      phase_components = config_phase_components_by_phase_titles(titles)
      config_error "No readiness assurance phase components found for titles #{titles}.", config if phase_components.blank?
      update_phase_components(phase_components, hash)
    end
  end

  def update_phase_components(phase_components, hash)
    phase_components.each do |phase_component|
      phase      = phase_component.thinkspace_casespace_phase
      assessment = create_assessment(phase, hash)
      save_phase_component(phase_component, assessment)
    end
  end

  def create_assessment(phase, hash)
    options   = hash[:assessment].deep_dup
    questions = [options[:questions] || []].flatten
    answers   = options[:answers] || {}
    answers   = answers.first if answers.is_a?(Array)
    options[:questions] = questions
    options[:answers]   = answers
    options[:user]      = find_user_by_name(hash[:user])
    options[:authable]  = phase
    create_model(:readiness_assurance, :assessment, options)
  end

end
