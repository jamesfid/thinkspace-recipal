class Thinkspace::Seed::Seed
  include ::Thinkspace::Seed::Classes
  include ::Thinkspace::Seed::Options

  attr_reader :configs

  delegate :color, to: :configs

  def process(seed)
    @seed    = seed
    @configs = @seed.configs
    options  = get_seed_options
    @seed.reset_tables if reset_tables?
    @configs.process(options)
    validate_phase_components
    test_only if @seed.test_only?
  end

  def reset_tables?
    ::Rails.env.development? # env.test is done via totem-test; should not do in production
  end

  def validate_phase_components
    phase_components = phase_component_class.where(componentable: nil).order(:id)
    return if phase_components.blank?
    @seed.message ''
    @seed.message color("The below (#{phase_components.length}) phase components are invalid (componentable is nil):", :red, :bold)
    puts ''
    phase_components.each_with_index do |phase_component, i|
      common_component = @seed.get_association(phase_component, :common, :component)
      puts color("#{(i+1).to_s.rjust(4)}. Phase Component".ljust(80,'-'), :yellow, :bold)
      @configs.models.print_model(phase_component)
      puts color((' ' * 8) + "Common Component:", :light_yellow)
      @configs.models.print_model(common_component, ' ' * 12)
    end
    @seed.error "Invalid phase components."
  end

  def test_only
    @seed.error "#{''.ljust(80, '-')}\nTESTING ONLY - PREVENT COMMITTING DB CHANGES."
  end

end
