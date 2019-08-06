class Thinkspace::Seed::IndentedLists < Thinkspace::Seed::BaseHelper

  def common_component_titles; [:indented_list, :diagnostic_path, :diagnostic_expert_path]; end

  def process(*args)
    super
    process_config
    process_auto_input if auto_input?
  end

  private

  def process_config
    default_settings = {layout: 'diagnostic_path'}
    assignment_phase_components_by_config_for_titles.each do |assignment, phase_components|
      @lists = Array.new
      phase_components.each do |phase_component|
        phase        = @seed.get_association(phase_component, :casespace, :phase)
        section_hash = phase_section_value(phase_component) || {}
        settings = section_hash.except(:phase, :expert).symbolize_keys
        expert   = section_hash[:expert] == true
        expert_settings(assignment, section_hash, settings) if expert
        title = phase.title
        settings.reverse_merge!(default_settings)
        list  = create_model(:indented_list, :list, authable: phase, title: title, expert: expert, settings: settings)
        save_phase_component(phase_component, list)
        @lists.push(list)
      end
    end
  end

  def expert_settings(assignment, section_hash, settings)
    title = section_hash[:phase]
    config_error "Indented list expert sections phase title is blank #{config.inspect}.", config  if title.blank?
    list_phase = find_phase(title: title, assignment: assignment)
    config_error "Indented list expert phase #{title.inspect} not found.", config  if list_phase.blank?
    phase_component = find_phase_component_for_phase(list_phase, :indented_list, :list)
    config_error "Indented list expert phase #{title.inspect} does not have an indented list phase component.", config  if phase_component.blank?
    list = phase_component.componentable
    config_error "Indented list expert phase #{title.inspect} with phase component [id: #{phase_component.id}] authable is blank."  if list.blank?
    settings[:list_id] = list.id
  end

  # ###
  # ### Auto Input.
  # ###

  def process_auto_input
    array = auto_input[:indented_list_responses]
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
      @expert_user.blank? ? process_non_expert : process_expert
    end

    def set_options(options)
      super
      @expert_user  = options[:expert]
      @expert_phase = options[:phase]
      @count        = options[:count]
      @state        = options[:state] || :active
      @ignore_obs   = options[:observations_list] == false
    end

    def process_non_expert
      @lists.each do |list|
        phase = list.authable
        next if skip_phase?(phase)
        @ignore_obs ? populate_without_observations(phase, list) : populate_with_observations(phase, list)
      end
    end

    def process_expert
      config_error "Indented list expert user [:expert] is blank", config if @expert_user.blank?
      config_error "Indented list expert phase [:phase] is blank", config if @expert_phase.blank?
      user = find_user_by_name(@expert_user)
      config_error "Indented list expert user #{@expert_user.inspect} not found", config if user.blank?
      phase = find_phase(title: @expert_phase)
      config_error "Indented list expert hash phase title #{@expert_phase.inspect} not found.", config if phase.blank?
      phase_component = find_phase_component_for_phase(phase, :indented_list, :list)
      config_error "Indented list expert phase #{phase.title.inspect} does not have an indented list component.", config if phase_component.blank?
      list = phase_component.componentable
      config_error "Indented list expert phase #{phase.title.inspect} does not have an indented list componentable.", config if list.blank?
      orig_list_id = list.settings['list_id']
      config_error "Indented list expert settings 'list_id' is blank #{list.inspect}.", config if orig_list_id.blank?
      response = @seed.model_class(:indented_list, :response).find_by(list_id: orig_list_id, ownerable: user)
      if !@ignore_obs
        config_error "Indented list expert #{@expert_user.inspect} does not have a response for list [id: #{orig_list_id}]\n  List: #{list.inspect}."  if response.blank?
        config_warn  "Indented list expert is poplulated from #{@expert_user.inspect} and 'count' value ignored.", config  if @count.present?
        config_warn  "Indented list expert is poplulated from #{@expert_user.inspect} and 'indent' value ignored.", config if @indent != 0
        populate_expert_response(phase, list, user, response)
      else
        populate_without_observations(phase, list)
      end
    end

    def populate_with_observations(phase, list)
      obs_lists     = @seed.model_class(:observation_list, :list).where(authable: phase).order(:id)
      ownerables    = find_phase_ownerables(phase)
      processed_ids = Array.new
      obs_lists.each do |olist|
        next if processed_ids.include?(olist.id)
        olist_lists = @seed.get_association(olist, :observation_list, :lists).order(:id).select {|l| !processed_ids.include?(l.id)}
        olist_ids      = olist_lists.map(&:id)
        processed_ids += olist_ids
        ownerables.each do |ownerable|
          next if skip_ownerable?(ownerable)
          observations = @seed.model_class(:observation_list, :observation).where(ownerable: ownerable, list_id: olist_ids).order(:id).to_a
          if observations.blank?
            config_warn "Ownerable #{ownerable_text(ownerable).inspect} observations are blank.  No indented list items added."
            next
          end
          item_count = @count.present? ? @count : observations.length
          add_response_for_ownerable(list, ownerable, observations, item_count)
        end
      end
    end

    def populate_without_observations(phase, list)
      return if @count.blank?
      find_phase_ownerables(phase).each do |ownerable|
        add_response_for_ownerable(list, ownerabl)
      end
    end

    def add_response_for_ownerable(list, ownerable, itemables=[], item_count=@count)
      value  = Hash.new
      items  = value[:items] = Array.new
      pos_x  = 0
      item_count.times do |y|
        pos_x    = 0  if pos_x >= @indent
        itemable = itemables[y]
        hash     = {pos_y: y, pos_x: pos_x}
        if itemable.present?
          hash[:itemable_id]         = itemable.id
          hash[:itemable_type]       = itemable.class.name
          hash[:itemable_value_path] = 'value'
          hash[:icon]                = get_itemable_icon(itemable)
        else
          hash[:description] = "auto: (#{y}:#{pos_x}) #{list.title}"
        end
        items.push(hash)
        pos_x += 1
      end
      response_hash = {
        list:      list,
        user_id:   list.authable.team_ownerable? ? 1 : ownerable.id,
        ownerable: ownerable,
        value:     value,
      }
      response = create_model(:indented_list, :response, response_hash)
    end

    def get_itemable_icon(itemable)
      icon = 'unknown'
      case
      when itemable.is_a?(@seed.model_class(:observation_list, :observation))
        list = @seed.get_association(itemable, :observation_list, :list)
        cat  = (list.category || Hash.new)['name']
        icon = convert_icon_category_to_id(cat)
      end
      icon
    end

    def convert_icon_category_to_id(cat)
      case (cat || '').downcase.to_sym
      when :d   then :lab
      when :h   then :html
      when :m   then :mechanism
      else           'none'
      end
    end

    # ###
    # ### ExpertResponses.
    # ###

    def populate_expert_response(phase, list, user, response)
      items     = (response.value || Hash.new)['items']
      orig_list = @seed.get_association(response, :indented_list, :list)
      config_error "Indened list response [id: #{response.id}] list not found.", config  if orig_list.blank?
      expert_items = Array.new
      items.each do |item|
        eitem = item.symbolize_keys.except(:itemable_id, :itemable_type, :itemable_value_path)
        add_expert_item_itemable_values(item, eitem)
        expert_items.push(eitem)
      end
      expert_hash  = {
        user:     user,
        list:     list,
        response: response,
        state:    @state,
        value:    {items: expert_items},
      }
      response = create_model(:indented_list, :response, expert_hash)
    end

    def add_expert_item_itemable_values(item, new_item)
      id       = item['itemable_id']
      type     = item['itemable_type']
      itemable = nil
      klass    = nil
      if type.present?
        config_error "Indented list itemable id is blank #{item.inspect}.", config  if id.blank?
        class_name = type.classify
        klass      = class_name.safe_constantize
        config_error "Indented list itemable class #{class_name.inspect} could not be constantized.", config if klass.blank?
        itemable = klass.find_by(id: id)
        config_error "Indented list itemable class #{class_name.inspect} [id: #{id}] not found.", config if itemable.blank?
      end
      if itemable.present?
        description, icon = get_expert_itemable_values(itemable)
      else
        id   ||= 'none'
        type ||= 'unknown'
        description = "auto: #{type}.#{id}"
        icon = nil
      end
      new_item[:description] = description
      new_item[:icon]        = icon  if icon.present?
    end

    def get_expert_itemable_values(itemable)
      description = itemable.value  if itemable.respond_to?(:value)
      icon        = get_itemable_icon(itemable)
      [description, icon]
    end

  end # AutoInput

end
