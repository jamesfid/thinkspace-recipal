# rake db:drop db:create totem:db:reset[none]
# rake thinkspace:migrate:assignments[../../migrate-ts-1-to-2/assignments]  #=> relative path to assignment xml direcotry

require File.expand_path('../helpers/require_all', __FILE__)
module Thinkspace; module Migrate; module Assignments
  class ParseXml

    include Helpers::Parse
    include Helpers::Node

    attr_reader :assignment
    attr_reader :assignment_item_types
    attr_reader :assignment_observation_lists
    attr_reader :assignment_diagnostic_paths

    def initialize(options={})
      @test_overrides = true
      @verbose        = false
      @debug          = true
    end

    def process(args=nil)
      start_time = Time.now
      print_message "\n"
      print_message "Start Time: #{start_time.to_s(:db)}"
      set_process_ids
      set_root_path(args)
      set_timeline_nodes
      ActiveRecord::Base.transaction do
        set_space
        set_user
        set_image_prefix
        set_remove_observation_links
        create_assignments
      end
      end_time     = Time.now
      elapsed_time = end_time.minus_with_coercion(start_time)
      print_message "\n"
      print_message "End Time: #{end_time.to_s(:db)}"
      print_message "Duration (HH:MM:SS): #{Time.at(elapsed_time).utc.strftime('%H:%M:%S')}"
    end

    def create_assignments
      get_assignment_nodes.each do |node|
        id = get_node_id(node)
        next if process_ids.present? && !process_ids.include?(id)
        @current_assignment_node = node
        create_assignment
        create_assignment_observation_list_group
      end
    end

    def create_assignment_observation_list_group
      return if assignment_observation_lists.blank?
      id    = get_node_id(current_assignment_node)
      title = get_assignment_title(id)
      group = Thinkspace::ObservationList::Group.create(groupable: assignment, title: timestamp_title(title))
      [assignment_observation_lists.values].flatten.compact.each do |list|
        Thinkspace::ObservationList::GroupList.create(list_id: list.id, group_id: group.id)
      end
    end

    # ###
    # ### Create Assignment.
    # ###

    def create_assignment
      id = get_node_id(current_assignment_node)
      set_current_assignment_path(id)
      hash                = Hash.new
      hash[:title]        = get_assignment_title(id)
      hash[:space_id]     = space && space.id
      hash[:state]        = 'active'
      hash[:release_at]   = nil
      hash[:due_at]       = nil
      hash[:name]         = nil
      hash[:bundle_type]  = 'casespace'
      hash[:description]  = nil
      hash[:instructions] = nil
      if test_overrides?
        # ###
        # ### Testing overrides
        hash[:release_at]   = Time.now - 1.days
        hash[:due_at]       = Time.now + 10.days
        # ### Testing overrides
        # ###
      end
      @assignment         = Thinkspace::Casespace::Assignment.create(hash)
      print_message "\n"  if verbose?
      print_message "-- Assignment xmlid:#{id} id:#{assignment.id} title: #{assignment.title.inspect}"
      @assignment_item_types        = get_assignment_item_type_nodes.collect {|node| ItemType.new(node)}
      @assignment_diagnostic_paths  = Array.new
      @assignment_observation_lists = Hash.new
      create_phases
    end

    def create_phases
      get_assignment_phase_nodes.each do |node|
        @current_phase_node = node
        create_phase
      end
    end

    # ###
    # ### Create Phase.
    # ###

    def create_phase
      hash                     = Hash.new
      hash[:title]             = get_phase_title
      hash[:state]             = 'inactive'
      hash[:position]          = get_phase_id.to_i
      hash[:phase_template_id] = get_phase_template_id
      hash[:team_category_id]  = get_phase_team_category_id
      hash[:description]       = nil
      hash[:default_state]     = get_phase_default_state
      if test_overrides?
        # ###
        # ### Testing overrides
        hash[:state] = 'active'
        # TODO: REMOVE COMMENT.
        #hash[:default_state] = 'unlocked'

        # ### Testing overrides
        # ###
      end
      phase = assignment.thinkspace_casespace_phases.create(hash)
      print_message "   ++ phase xmlid:#{get_phase_id} id:#{phase.id} title: #{phase.title.inspect}"  if verbose?
      create_phase_components(phase)
      create_phase_configuration(phase)
    end

    def create_phase_configuration(phase)
      hash = Hash.new
      hash[:action_submit_server] = Array.new
      hash[:action_submit_server] << {event: :unlock_phase, phase_id: :next}
      hash[:action_submit_server] << {event: :complete_phase, phase_id: :self}
      hash[:phase_score_validation]                                        = Hash.new
      hash[:phase_score_validation][:numericality]                         = Hash.new
      hash[:phase_score_validation][:numericality][:less_than_or_equal_to] = get_phase_sub_score || 0
      hash[:phase_score_validation][:validation]                           = Hash.new
      hash[:phase_score_validation][:validation][:validate]                = true
      hash[:phase_score_validation][:submit]                               = Hash.new
      hash[:phase_score_validation][:submit][:visible]                     = true
      hash[:phase_score_validation][:submit][:text]                        = @submit_text || 'Submit'
      Thinkspace::Common::Configuration.create(configurable: phase, settings: hash)
    end

    def create_phase_components(phase)
      @submit_text = nil
      case get_phase_type
      when 'content-items'
        create_header_component(phase)
        create_html_component(phase, select_text: true)
        create_observation_list_component(phase, 'H')
        create_submit_component(phase)
      when 'labtest'
        create_header_component(phase)
        create_lab_component(phase)
        create_observation_list_component(phase, 'D')
        create_submit_component(phase)
      when 'diagnosticpath'
        create_header_component(phase)
        create_diagnostic_path_component(phase)
        create_observation_list_component(phase, 'M')
        create_submit_component(phase)
      when 'content'
        create_header_component(phase)
        create_html_component(phase)
        create_submit_component(phase)
      when 'expertpath'
        create_header_component(phase)
        create_diagnostic_path_viewer_component(phase)
        create_submit_component(phase)
      else
        stop_run "Unknown phase type #{type.inspect} in #{current_assignment_path.inspect}."
      end
    end

    # ###
    # ### Lab Components.
    # ###

    def create_lab_component(phase)
      id          = get_phase_id
      phase_node  = get_phase_node(id)
      chart_nodes = phase_node.css('labtest')
      raise_error 'No lab test chart nodes.'  if chart_nodes.blank?
      title         = "Lab chart for phase #{phase.title}"
      componentable = Thinkspace::Lab::Chart.create(authable: phase, title: title)
      create_phase_component(phase, componentable, 'lab', 'chart')
      create_lab_categories_and_results(componentable, chart_nodes)
    end

    def create_lab_categories_and_results(chart, nodes)
      Helpers::LabChart.new(self, nodes).categories.each do |key, hash|
        results  = hash.delete(:results)
        category = Thinkspace::Lab::Category.create(hash.merge(chart_id: chart.id))
        results.each do |result|
          units = result[:value][:columns][:units]
          result[:value][:columns][:units] = units.dup.force_encoding('ISO-8859-1').encode('UTF-8') if units
          Thinkspace::Lab::Result.create(result.merge(category_id: category.id))
        end
      end
    end

    # ###
    # ### Phase Header/Submit Components.
    # ###

    def create_header_component(phase); create_phase_component(phase, phase, 'casespace-phase-header', 'header'); end
    def create_submit_component(phase); create_phase_component(phase, phase, 'casespace-phase-submit', 'submit'); end

    # ###
    # ### Diagnostic Path Component.
    # ###

    def create_diagnostic_path_component(phase)
      title         = 'Diagnostic Path'
      componentable = Thinkspace::DiagnosticPath::Path.new(authable: phase, title: title)
      assignment_diagnostic_paths.push(componentable)
      create_phase_component(phase, componentable, 'diagnostic-path', 'diag-path')
    end

    # ###
    # ### Observation List Component.
    # ###

    def create_observation_list_component(phase, default_item_type)
      item_type = get_phase_item_type
      item_type = default_item_type  if item_type.blank?
      print_debug "Duplicate phase observation list item type #{item_type.inspect}", ids: true  if assignment_observation_lists.has_key?(item_type)
      category      = get_item_type_category(item_type)
      componentable = Thinkspace::ObservationList::List.create(authable: phase, category: category)
      assignment_observation_lists[item_type] ||= Array.new
      assignment_observation_lists[item_type].push(componentable)
      create_phase_component(phase, componentable, 'observation-list', 'obs-list')
    end

    # ###
    # ### HTML Component.
    # ###

    def create_html_component(phase, options={})
      id         = get_phase_id
      phase_node = get_phase_node(id)
      content    = find_node_value(phase_node, :content)
      raise_error 'No html content.'  if content.blank?
      doc     = parse_html(content)
      buttons = doc.search('input[type="button"]')
      buttons.each do |button|
        name = button.attribute('name').text
        next unless name == 'submit'
        @submit_text = button.attribute('value').text
        button.remove
      end
      images = doc.search('img')
      images.each do |image|
        src                          = image.attribute('src').text
        file_name                    = src.split('/').pop
        new_src                      = get_image_src_for_file_name(file_name)
        next unless new_src.present?
        image.attribute('src').value = new_src
      end
      html_content  = doc.to_s
      componentable = Thinkspace::Html::Content.create(authable: phase, html_content: html_content)
      create_html_content_input_elements(componentable)
      component_title = options[:select_text].present? ? 'html-select-text' : 'html'
      create_phase_component(phase, componentable, component_title, 'html')
    end

    def get_image_src_for_file_name(file_name)
      return file_name unless image_prefix.present?
      image_prefix + "/#{file_name}"
    end
    
    def create_html_content_input_elements(componentable)
      names = get_input_element_names(componentable.html_content)
      names.each do |hash|
        name = hash[:name]
        type = hash[:element_type]
        element = componentable.thinkspace_input_element_elements.create(name: name, element_type: type, componentable: componentable)
      end
    end

    def get_input_element_names(html_content)
      input_names = Array.new
      radio       = Hash.new
      html        = parse_html(html_content)
      inputs      = html.css('input')
      inputs.each do |input|
        name         = input['name']
        element_type = input['type']
        element_type == 'radio' ? radio[name] = element_type : input_names.push({name: name, element_type: element_type})
      end
      inputs = html.css('textarea')
      inputs.each do |input|
        input_names.push({name: input['name'], element_type: 'textarea'})
      end
      radio.each {|name, type| input_names.push({name: name, element_type: type})}
      input_names
    end
    
    # ###
    # ### Diagnostic Path Viewer Component.
    # ###

    def create_diagnostic_path_viewer_component(phase)
      diagnostic_path = assignment_diagnostic_paths.last
      raise_error "Assignment does not have any diagnostic paths."  if diagnostic_path.blank?
      # Expert side.
      componentable   = Thinkspace::DiagnosticPathViewer::Viewer.create(
        authable:  phase,
        path_id:   diagnostic_path.id,
        ownerable: user,
        user_id:   user && user.id
      )
      create_phase_component(phase, componentable, 'diagnostic-path-viewer', 'diag-path-viewer')
      # Student side.
      create_phase_component(phase, componentable, 'diagnostic-path-viewer-ownerable', 'diag-path-viewer-ownerable')
      # Create html for above.
      nodes = get_assignment_diagnosis_nodes
      create_diagnostic_path_viewer_html_components(phase, nodes)
      create_diagnostic_path_viewer_expert_values(phase, diagnostic_path, nodes)
    end

    def create_diagnostic_path_viewer_html_components(phase, nodes)
      # Expert side.
      diagnosis_node = nodes.css('diagnosis')
      comment        = find_node_value(diagnosis_node, :comment)
      html_content   = "<h3>Diagnosis: #{comment}</h3>"
      componentable  = Thinkspace::Html::Content.create(authable: phase, html_content: html_content)
      create_phase_component(phase, componentable, 'html', 'html-viewer')
      # Student side.
      comment       = '<thinkspace type="carry_forward" name="diagnosis"></thinkspace>'
      html_content  = "<h3>Diagnosis: #{comment}</h3>"
      componentable = Thinkspace::Html::Content.create(authable: phase, html_content: html_content)
      create_phase_component(phase, componentable, 'html', 'html-ownerable')
    end

    def create_diagnostic_path_viewer_expert_values(phase, diagnostic_path, nodes)
      items = nodes.css('item')
      raise_error "Items are blank for path viewer."  if items.blank?
      observations = create_diagnostic_path_viewer_expert_observations(items)
      create_diagnostic_path_viewer_expert_path_items(items, diagnostic_path, observations)
    end

    def create_diagnostic_path_viewer_expert_observations(items)
      observations = Hash.new
      items.each do |node|
        id = get_node_id(node)
        raise_error "Diagnosis item has a blank id."  if id.blank?
        item_type = find_node_value(node, :type)
        list      = (assignment_observation_lists[item_type] || []).first
        if list.blank?
          item_type = 'D' # TODO: What to do here?  Defaulting custom item types to D.
          list      = (assignment_observation_lists[item_type] || []).first
        end
        raise_error "Observation list for item type #{item_type.inspect} not found."  if list.blank?
        value             = get_observation_value_for_node(node, :label)
        position          = id.to_i
        next if item_type == 'M' # Do not create observations for Mechanisms.
        observation       = list.thinkspace_observation_list_observations.create(
          position:  position,
          value:     value,
          ownerable: user,
          user_id:   user && user.id
        )
        observations[id] = observation
      end
      observations
    end

    def create_diagnostic_path_viewer_expert_path_items(items, path, observations)
      indent_parents  = Hash.new
      indent_position = Hash.new(0)
      items.each do |node|
        id          = get_node_id(node)
        observation = observations[id]
        # raise_error "Observation is blank for path item id #{id}."  if observation.blank?
        indent   = find_node_value(node, :indent).to_i
        parent   = indent_parents[indent]
        position = indent_position[indent] 
        indent_position.keys.each {|k| indent_position.delete(k)  if k > indent}
        if observation.present?
          path_item = path.thinkspace_diagnostic_path_path_items.create(
            parent_id:     parent && parent.id,
            position:      position,
            path_itemable: observation,
            ownerable:     user,
            user_id:       user && user.id,
          )
        else
          value = get_observation_value_for_node(node, :label)
          path_item = path.thinkspace_diagnostic_path_path_items.create(
            parent_id:     parent && parent.id,
            position:      position,
            description:   value,
            ownerable:     user,
            user_id:       user && user.id,
          )
        end
        indent_parents[indent + 1] = path_item
        indent_position[indent] += 1
      end
    end

    def get_observation_value_for_node(node, attribute=:label)
      value = find_node_value(node, :label)
      link_check = ::Nokogiri::HTML(value).css('a')
      if link_check.present? and @remove_observation_links
        raise_error "Cannot remove links as there are more than one [#{link_check.length}]" if link_check.length > 1
        value = link_check.text
      end
      value
    end

    # ###
    # ### Component Helper.
    # ###

    def create_phase_component(phase, componentable, component_title, section)
      component = Thinkspace::Common::Component.find_by(title: component_title)
      raise_error "Component with title #{component_title.inspect} not found."  if component.blank?
      phase_component = phase.thinkspace_casespace_phase_components.create(
        componentable: componentable,
        component_id:  component.id,
        section:       section
      )
      print_message "      + component: #{component_title.inspect} section: #{section.inspect} componentable: #{componentable.class.name}.#{componentable.id}"  if verbose?
      phase_component
    end

  end # class

end; end; end
