class Thinkspace::Seed::Labs < Thinkspace::Seed::BaseHelper

  def common_component_titles; [:lab]; end

  def process(*args)
    super
    process_config
  end

  private

  def process_config
    @labs = [config[:labs]].flatten.compact
    return if @labs.blank?
    phase_components = phase_components_by_config
    phase_components.each do |phase_component|
      phase = @seed.get_association(phase_component, :casespace, :phase)
      chart = create_chart(phase)
      save_phase_component(phase_component, chart)
    end
  end

  def create_chart(phase)
    @lab_hash = @labs.find {|h| h[:phase] == phase.title}
    config_error "Lab chart for phase #{phase.title.inspect} not found.", config if @lab_hash.blank?
    hash = @lab_hash[:chart]
    config_error "Lab chart is blank for phase #{phase.title.inspect}. #{@lab_hash.inspect}", config if hash.blank?
    title = hash[:title]
    config_error "Lab chart title is blank. #{hash.inspect}", config if title.blank?
    chart = create_model(:lab, :chart, title: title, authable: phase)
    config_error "Lab chart is blank.", config if chart.blank?
    add_categories(chart, hash)
    chart
  end

  def add_categories(chart, chart_hash)
    categories = [chart_hash[:categories]].flatten.compact
    config_error "Lab chart #{chart.title.inspect} does not have any categories.\n\n #{@lab_hash.inspect}", config if categories.blank?
    categories.each_with_index do |hash, i|
      title = hash[:title]
      config_error "Lab chart category title is blank. #{hash.inspect}", config if title.blank?
      blueprint = @lab_hash.dig(:blueprint, :category)
      config_error "Lab chart category blueprint is blank. #{hash.inspect}", config if blueprint.blank?
      config_error "Lab chart category blueprint is not a hash. #{hash.inspect}", config unless blueprint.is_a?(Hash)
      category = create_model(:lab, :category, blueprint.deep_merge(title: title, chart: chart, position: i))
      config_error "Lab chart #{chart.title.inspect} category #{title.inspect} is blank. #{category_hash.inspect}", config if category.blank?
      add_category_results(category, hash)
    end
  end

  def add_category_results(category, category_hash)
    results = [category_hash[:results]].flatten.compact
    results.each_with_index do |blueprint_name, i|
      blueprint = @lab_hash.dig(:blueprint, :results, blueprint_name.to_sym)
      config_error "Lab chart blueprint name #{blueprint_name.inspect} is not a hash.", config unless blueprint.is_a?(Hash)
      create_model(:lab, :result, blueprint.merge(category: category, position: i+1))
    end
  end

end
