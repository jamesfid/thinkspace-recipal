class Thinkspace::Seed::Simulations < Thinkspace::Seed::BaseHelper

  def common_component_titles; [:simulation]; end

  def process(*args)
    super
    process_config
  end

  private

  def process_config
    phase_components = phase_components_by_config
    phase_components.each do |phase_component|
      phase            = @seed.get_association(phase_component, :casespace, :phase)
      common_component = @seed.get_association(phase_component, :common, :component)
      section_hash     = phase_section_value(phase_component) || {}
      title            = section_hash[:title] || phase.title
      path             = section_hash[:path]
      config_error "Simulation section #{common_component.section.inspect} does not have a path #{config.inspect}.", config  if path.blank?
      simulation = create_model(:simulation, :simulation, authable: phase, title: title, path: path)
      save_phase_component(phase_component, simulation)
    end
  end

end
