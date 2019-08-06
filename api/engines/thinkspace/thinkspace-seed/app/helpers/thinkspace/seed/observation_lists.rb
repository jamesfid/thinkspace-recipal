class Thinkspace::Seed::ObservationLists < Thinkspace::Seed::BaseHelper

  def common_component_titles; [:observation_list, :obs_list]; end

  def process(*args)
    super
    process_config
    process_auto_input if auto_input?
  end

  private

  def process_config
    assignment_phase_components_by_config_for_titles.each do |assignment, phase_components|
      @lists = Array.new
      phase_components.each do |phase_component|
        phase        = @seed.get_association(phase_component, :casespace, :phase)
        section_hash = phase_section_value(phase_component) || {}
        category     = section_hash[:category] || {name: observation_list_category_name(phase)}
        list         = create_model(:observation_list, :list, authable: phase, category: category)
        save_phase_component(phase_component, list)
        @lists.push(list)
      end
      observation_list_group(assignment) if @lists.present?
    end
  end

  # Set the category name based on the other components defined in the phase template.
  # Using a 'match' so may not be 100% accruate but should be correct most of the time
  # or can add in the phase's sections e.g. {obs-list: {category: {name: H|D|M}}.
  # diagnostic-path = 'M'; lab = 'D'; html = 'H'
  def observation_list_category_name(phase)
    phase_template = @seed.get_association(phase, :casespace, :phase_template)
    template       = phase_template.template || ''
    case
    when template.match('diagnostic-path') then 'M'
    when template.match('lab')             then 'D'
    when template.match('html')            then 'H'
    else 'H'  # default
    end
  end

  def observation_list_group(assignment)
    title       = "#{assignment.title} [id: #{assignment.id}] group title"
    obs_group   = create_model(:observation_list, :group, title: title, groupable: assignment)
    @lists.each do |list|
      create_model(:observation_list, :group_list, group: obs_group, list: list)
    end
  end

  # ###
  # ### Auto Input.
  # ###

  def process_auto_input
    array = auto_input[:observations]
    return if array.blank?
    array.each do |options|
      AutoInput.new(@seed, @configs).process(config, @lists, options)
    end
  end

  class AutoInput < ::Thinkspace::Seed::BaseHelper
    include ::Thinkspace::Seed::AutoInput

    def process(config, lists, options)
      @config = config
      @lists  = lists
      set_options(options)
      add_observations
    end

    def set_options(options)
      super
      @obs_per_list  = options[:observations_per_list] || 3
      @notes_per_obs = options[:notes_per_observation] || 3
    end

    def add_observations
      @lists.each do |list|
        phase = list.authable
        next if skip_phase?(phase)
        ownerables = find_phase_ownerables(phase)
        ownerables.each do |ownerable|
          next if skip_ownerable?(ownerable)
          clear_current_indent
          user = team?(ownerable) ? user_class.first : ownerable
          @obs_per_list.times do |o|
            value       = observation_value(phase, ownerable, list, o+1)
            observation = create_model(:observation_list, :observation, user: user, ownerable: ownerable, list: list, position: o+1, value: value)
            @notes_per_obs.times do |n|
              value = note_value(observation, n+1)
              create_model(:observation_list, :observation_note, observation: observation, value: value)
            end
          end
        end
      end
    end

    def observation_value(phase, ownerable, list, n)
      text  = indent_text
      text += "List.#{list.id} "
      text += "#{ownerable_text(ownerable)}.#{ownerable.id} "
      text += "Pos.#{n} "
      text += "Phase.#{phase.id}[#{phase.title}]"
      text
    end

    def note_value(observation, n)
      "#{n}. Note for observation.#{observation.id}."
    end

  end # AutoInput

end
