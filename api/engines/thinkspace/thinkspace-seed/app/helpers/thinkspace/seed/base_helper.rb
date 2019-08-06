class Thinkspace::Seed::BaseHelper < Totem::Seed::BaseHelper
  include ::Thinkspace::Seed::Classes
  include ::Thinkspace::Seed::Finders
  include ::Thinkspace::Seed::Components
  include ::Thinkspace::Seed::CreateOptions
  include ::Thinkspace::Seed::Options

  def process(*args)
    super
    @find_model_to_model_id = get_seed_options_model_to_model_id
    return if config_keys.present?
    process_componentable_message
    process_general_message unless common_component_titles.present?
  end

  def common_component_titles; []; end

  def process_componentable_message
    return if @printed_componentable_message
    titles = common_component_titles
    return if titles.blank?
    titles = titles.join(', ').ljust(30)
    @seed.message color("++phase template component titles: #{titles} [#{self.class.name}]", :light_green)
    @printed_componentable_message = true
  end

  def process_general_message
    return if @printed_general_message
    @seed.message color("++processing helper [#{self.class.name}]", :light_green)
    @printed_general_message = true
  end

end
