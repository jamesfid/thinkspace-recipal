module Thinkspace::Seed::Components

  def common_component_ids_like(*titles); common_component_titles_like(*titles).map(&:id).uniq; end

  # TODO: Find better approach to find a common component instead of title match.  e.g. add somethinkg to compoents.yml?
  #       Previously was using component.value.path match but path shouldn't be needed with ember engines.
  # NOTE: In a postgres 'like' pattern, '_' (underscore) will match any single character.
  def common_component_titles_like(*titles)
    records = Array.new
    titles.each do |title|
      records += common_component_class.where("title LIKE '%#{title}%'")
    end
    records
  end

  def common_component_ids; @common_component_ids ||= common_component_ids_like(*common_component_titles); end

  def phase_componentable?(common_component); common_component.title.match('casespace-phase'); end

  def phases_by_config     (cfg=config); config_models_for_key(:phases, cfg); end
  def assignments_by_config(cfg=config); config_models_for_key(:assignments, cfg); end

  def phase_ids_by_config(cfg=config); phases_by_config(cfg).map(&:id); end

  def config_phases_for_titles(titles, cfg=config)
    titles = [titles].flatten.compact
    return [] if titles.blank?
    phases_by_config(cfg).select {|p| titles.include?(p.title)}
  end

  def assignment_phase_components_by_config_for_titles(cfg=config)
    hash        = ActiveSupport::OrderedHash.new
    assignments = assignments_by_config
    assignments.each do |assignment|
      phase_ids = @seed.get_association(assignment, :casespace, :phases).pluck(:id).sort
      hash[assignment] = phase_components_by_config(cfg, phase_ids)
    end
    hash
  end

  def phase_components_by_config(cfg=config, phase_ids=nil)
    phase_ids ||= phase_ids_by_config(cfg)
    phase_component_class.where(phase_id: phase_ids, component_id: common_component_ids, componentable: nil).order(:id)
  end

  def config_phase_components_by_phase_titles(titles, cfg=config)
    titles    = [titles].flatten.compact
    phase_ids = config_phases_for_titles(titles, cfg).map(&:id)
    phase_components_by_config(cfg, phase_ids).select {|pc| phase_ids.include?(pc.phase_id)}
  end

  def config_models_for_key(key, cfg=config); @configs.helper_by_key(key).config_models[cfg] || []; end

  def phase_section_value(phase_component)
    hash = phases_helper.phase_sections[phase_component.phase_id]
    return hash unless hash.is_a?(Hash)
    section = (phase_component.section || '').to_sym
    hash[section]
  end

  def phases_helper; @configs.helper_by_key(:phases); end

  def save_phase_component(phase_component, componentable)
    phase_component.componentable = componentable
    save_model(phase_component)
  end

end
