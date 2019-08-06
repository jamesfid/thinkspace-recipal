# e.g. rake thinkspace:migrate:diagnostic_paths_to_indented_lists:phases[1,2,3]
require File.expand_path('../helpers/require_all', __FILE__)
module Thinkspace; module Migrate; module DiagnosticPathsToIndentedLists; class Process
  # See run help at bottom of file.

  include Helpers::RakeProcesses

  def process(method, args)
    print_start
    stop_run "#{self.class.name.inspect} does not respond to #{method.to_s.inspect}"  unless self.respond_to?(method)
    init_variables
    args = [args].flatten.compact.collect {|a| a.strip}
    self.send method, args
    print_summary
    print_end
  end

  def init_variables
    @destroy_path               = false
    @debug                      = false
    @phases_converted           = 0
    @phase_components_converted = 0
    @lists_created              = 0
    @responses_created          = 0
    @paths_destroyed            = 0
  end


  # ###
  # ### Convert Expert Phases
  # ###

  def convert_phases_to_expert_indented_lists
    phases = expert_phase_scope
    ActiveRecord::Base.transaction do
      phases.each do |phase|
        process_expert_phase(phase)
        convert_phase_to_list_phase_template(phase, true)
      end
    end
  end

  def process_expert_phase(phase)
    phase_components = phase.thinkspace_casespace_phase_components
    return if phase_components.blank?
    sections_to_keep = ['header', 'submit']
    phase_components.each do |phase_component|
      case
      when phase_component.section == 'diag-path-viewer'
        process_expert_phase_component(phase, phase_component)
      when !sections_to_keep.include?(phase_component.section)
        phase_component.destroy
      end
    end
  end

  def process_expert_phase_component(phase, phase_component)
    viewer                       = phase_component.componentable
    path                         = viewer.thinkspace_diagnostic_path_path
    authable                     = path.authable
    authable_list                = get_list_from_authable(authable)
    options                      = Hash.new
    options[:settings]           = {layout: 'diagnostic_path'}
    options[:settings][:list_id] = authable_list.id if authable_list.present?
    options[:expert]             = true
    list                         = create_list(phase, nil, options)
    convert_phase_component_to_list(phase, phase_component, list)
    process_expert_path(viewer, authable_list, list)
  end

  def get_list_from_authable(authable)
    return unless authable.present?
    pc = authable.thinkspace_casespace_phase_components.find_by(componentable_type: list_class.name)
    pc.present? && pc.componentable.present? ? pc.componentable : nil
  end

  def process_expert_path(viewer, authable_list, list)
    expert   = viewer.ownerable
    response = response_class.find_by(ownerable: expert, list_id: authable_list.id)
    return unless response.present?
    items = response.value.with_indifferent_access[:items] || Array.new
    return unless items.present? && items.kind_of?(Array)
    expert_items = Array.new
    items.each do |item|
      new_item = {
        category: item[:category],
        description: get_description_from_item(item),
        pos_x: item[:pos_x],
        pos_y: item[:pos_y]
      }
      expert_items << new_item
    end
    expert_response             = expert_response_class.new
    expert_response.value       = {items: expert_items}
    expert_response.user_id     = expert.id
    expert_response.list_id     = list.id
    expert_response.response_id = response.id
    expert_response.state       = 'active'
    expert_response.save
    expert_response
  end

  def get_description_from_item(item)
    return item[:description] if item.has_key?(:description) && item[:description].present?
    type       = item[:itemable_type]
    id         = item[:itemable_id]
    value_path = item[:itemable_value_path] || 'value'
    return nil unless type.present? && id.present? && value_path.present?
    klass      = type.safe_constantize
    return nil unless klass.present?
    record = klass.find(id)
    return nil unless record.present?
    record.send value_path
  end


  # ###
  # ### Convert Phases.
  # ###

  def convert_phases_to_indented_lists
    phases = phase_scope
    ActiveRecord::Base.transaction do
      phases.each do |phase|
        process_phase(phase)
        convert_phase_to_list_phase_template(phase)
      end
      check_for_errors
    end
  end

  def process_phase(phase)
    phase_components = phase.thinkspace_casespace_phase_components.where(componentable_type: path_class.name)
    phase_components = phase_components.where(componentable_id: @path_ids)  if @path_ids.present?
    return if phase_components.blank?
    Helpers::PhaseTemplates.new.validate_phase_templates(phase, get_list_phase_template)
    phase_components.each do |phase_component|
      process_phase_component(phase, phase_component)
    end
  end

  def process_phase_component(phase, phase_component)
    path = phase_component.componentable
    list = create_list(phase, path)
    convert_phase_component_to_list(phase, phase_component, list)
    process_path(phase, path, list)
    if destroy_path?
      path.destroy
      @paths_destroyed += 1
    end
  end

  def destroy_path?; @destroy_path == true; end

  def process_path(phase, path, list)
    ownerables = get_path_ownerables(path)
    ownerables.each do |ownerable|
      user           = validate_and_get_path_items_user(path, ownerable)
      response_items = Helpers::BuildItems.new(path, ownerable, debug: @debug).process
      response       = create_response(phase, list, ownerable, user, response_items)
    end
  end

  def get_path_ownerables(path)
    ownerables = Array.new
    get_unique_path_ownerable_type_and_ids(path).each do |o|
      type  = o.ownerable_type
      ids   = o.ownerable_ids
      klass = type.safe_constantize
      raise_error "Path item ownerable #{type.inspect} cannot be constantized for path #{path.inspect}."  if klass.blank?
      ids.each do |id|
        record = klass.find_by(id: id)
        raise_error "Path item ownerable #{type.inspect}.#{id.inspect} no longer exists for path #{path.inspect}."  if record.blank?
        ownerables.push(record)
      end
    end
    ownerables
  end

   # Verify all of a ownerable's path items have same user_id.
  def validate_and_get_path_items_user(path, ownerable)
    path_items = path.thinkspace_diagnostic_path_path_items.where(ownerable: ownerable)
    user_ids   = path_items.pluck(:user_id).compact.uniq
    if user_ids.length > 1
      convert_user_id_to_ownerable(path_items, ownerable)
    end
    id   = user_ids.first
    user = user_class.find_by(id: id)
    raise_error "Path item user id #{id} does not exist for path #{path.inspect} and ownerable #{ownerable.inspect}"  if user.blank?
    user
  end

  def convert_user_id_to_ownerable(path_items, ownerable)
    path_items.each do |path_item|
      path_item.user_id = ownerable.id
      path_item.save
    end
  end

  def check_for_errors
    message = nil
    if @phases_converted > 0
      case
      when @phase_components_converted == 0  then message = 'no phase components were converted'
      when @lists_created == 0               then message = 'no indented lists were created'
      end
    end
    if message.present?
      print_summary
      raise_error "Phases were converted (#{@phases_converted}) but #{message}.  Changes rolled back."
    end
  end

  # ###
  # ### Convert Phase to Indented List.
  # ###

  def convert_phase_to_list_phase_template(phase, expert=false)
    expert ? list_phase_template = get_expert_list_phase_template : list_phase_template = get_list_phase_template
    raise_error "Indented list phase template not found."  if list_phase_template.blank?
    phase.thinkspace_casespace_phase_template = list_phase_template
    raise_error "Could not save the phase after changing to the list phase template #{phase.inspect}.  .  Validation errors: #{phase.errors.messages}"  unless phase.save
    @phases_converted  += 1
  end

  def convert_phase_component_to_list(phase, phase_component, list)
    component = get_list_component(phase)
    raise_error "Indented list common component not found."  if component.blank?
    section = get_list_phase_component_section
    raise_error "Indented list phase component section is blank #{phase_component.inspect}."  if section.blank?
    phase_component.thinkspace_common_component = component
    phase_component.componentable               = list
    phase_component.section                     = section
    raise_error "Could not save phase component after changing to list #{phase_component.inspect}.  Validation errors: #{phase_component.errors.messages}"  unless phase_component.save
    @phase_components_converted += 1
  end

  # ###
  # ### Get Indented List Domain Data.
  # ###

  def get_list_component(phase)
    @list_component ||= Helpers::PhaseTemplates.new.get_list_common_component
  end

  def get_list_phase_template
    @list_phase_template ||= Helpers::PhaseTemplates.new.get_list_phase_template
  end

  def get_expert_list_phase_template
    @get_expert_list_phase_template ||= Helpers::PhaseTemplates.new.get_expert_list_phase_template
  end

  def get_list_phase_component_section
    @list_phase_component_section ||= Helpers::PhaseTemplates.new.get_phase_component_section_in_list_template(get_list_phase_template)
  end

  # ###
  # ### Create Indented List Records.
  # ###

  def create_list(phase, path, options={})
    @lists_created += 1
    settings        = options[:settings] || {layout: 'diagnostic_path'}
    (options.has_key?(:expert) && options[:expert]) ? expert = true : expert = false
    path.present? ? title = path.title : title = 'Expert Path'
    list_class.create(
      authable_id:   phase.id,
      authable_type: phase.class.name,
      title:         title,
      settings:      settings,
      expert:        expert
    )
  end

  def create_response(phase, list, ownerable, user, items)
    @responses_created += 1
    user_id             = user.blank? ? nil : user.id
    response_class.create(
      user_id:        user_id,
      list_id:        list.id,
      ownerable_id:   ownerable.id,
      ownerable_type: ownerable.class.name,
      value:          {items: items},
    )
  end

  # ###
  # ### Scopes and Classes.
  # ###

  def get_phases_with_paths
    phase_scope.distinct.
      joins(:thinkspace_casespace_phase_components).
      where(thinkspace_casespace_phase_components: {componentable_type: path_class.name}).
      order(:id)
  end

  def get_unique_path_ownerable_type_and_ids(path)
    path.thinkspace_diagnostic_path_path_items.
      select(:ownerable_type).
      select('array_agg(distinct ownerable_id) as ownerable_ids').
      group(:ownerable_type).
      order(:ownerable_type)
  end

  def user_class;            ::Thinkspace::Common::User; end
  def space_class;           ::Thinkspace::Common::Space; end
  def assignment_class;      ::Thinkspace::Casespace::Assignment; end
  def phase_class;           ::Thinkspace::Casespace::Phase; end
  def path_class;            ::Thinkspace::DiagnosticPath::Path; end
  def path_item_class;       ::Thinkspace::DiagnosticPath::PathItem; end
  def path_viewer_class;     ::Thinkspace::DiagnosticPathViewer::Viewer; end
  def list_class;            ::Thinkspace::IndentedList::List; end
  def response_class;        ::Thinkspace::IndentedList::Response; end
  def expert_response_class; ::Thinkspace::IndentedList::ExpertResponse; end

  # ###
  # ### Print.
  # ###

  def print_message(message='')
    puts "[thinkspace:path2list] " + message
  end

  def print_summary
    print_message
    print_message "Summary:"
    hash                              = Hash.new
    hash[:phases_converted]           = @phases_converted
    hash[:phase_components_converted] = @phase_components_converted
    hash[:indented_lists_created]     = @lists_created
    hash[:indented_responses_created] = @responses_created
    hash[:paths_destroyed]            = @paths_destroyed
    print_hash(hash)
  end

  def print_start
    @start_time = Time.now
    print_message "\n"
    print_message "Start Time: #{@start_time.to_s(:db)}"
  end

  def print_end
    end_time     = Time.now
    elapsed_time = end_time.minus_with_coercion(@start_time)
    print_message "\n"
    print_message "End Time: #{end_time.to_s(:db)}"
    print_message "Duration (HH:MM:SS): #{Time.at(elapsed_time).utc.strftime('%H:%M:%S')}"
    print_message    
  end

  def print_hash(hash)
    max_key = hash.keys.collect {|k| k.to_s.length}.max || 1
    max_key += 2
    hash.keys.each do |key|
      k = key.to_s.humanize.ljust(max_key, '.')
      v = hash[key]
      print_message "  #{k}: #{v}"
    end
  end

  # ###
  # ### Errors.
  # ###

  def stop_run(message='')
    print_message
    print_message '*** ERROR ***'
    print_message(message)
    print_message('Run stopped.')
    print_end
    exit
  end

  def raise_error(message='')
    raise ConvertIndentedListError, message
  end

  class ConvertIndentedListError < StandardError; end

end; end; end; end

# Run help:
#   CAUTION: FOR RAKE TASKS, NO SPACES ARE ALLOWED BETWEEN ARGUMENTS  right: [1,2,3]  wrong: [1, 2, 3]
#
#   NOTE: the Helpers::PhaseTemplate class should be modified to match the typical run's domain data (and seed data).
#
#   Potential Errors:
#     - The phase's phase template (e.g. for the diagnostic path) is changed to the indent list's phase template but
#       only the diagnostic path's phase_component is updated to be the indented list (the other phase's phase_components
#       remain unchanged). Therefore the other phase_component must be compatible with the indented list's phase template.
#       This means the other phase_component's section and title values must be the same (except for the diagnostic path component itself).
#       When the phase_template includes an observation list, the indented list's 'source' must match the section value of the
#       of the observation list's component.
#       The Helpers::PhaseTemplate class performs some compatibility validation checks, but they are not 100%.
#       Examples:
##         bad:
#           existing path template: <component section='header'       title='casespace-phase-header'/>
#           indented list template: <component section='phase-header' title='casespace-phase-header'/>
#         good (must match existing header title and section):
#           existing path template: <component section='header' title='casespace-phase-header'/>
#           indented list template: <component section='header' title='casespace-phase-header'/>
##         bad:
#           existing path template: <component section='diag-path'     title='diagnostic-path' source='obs-list'/>
#           indented list template: <component section='indented-list' title='indented-list'   source='observation-list'/>
#         good (must match existing observation list's section):
#           existing path template: <component section='diag-path'     title='diagnostic-path' source='obs-list'/>
#           indented list template: <component section='indented-list' title='indented-list'   source='obs-list'/>
#     - The same applies to any seeds when they include phase templates.
#
#
#   General rake task format:
#     rake thinkspace:migrate:diagnostic_paths_to_indented_lists:{task}[{options}]
#
#     task: [spaces|assignments|phases|paths|all]
#           except for task 'all', the task identifies the model used for the options ids
#           CAUTION: task 'all' will process all paths in all phases.
#
#     options: [#|destroy_path|debug|component:#|phase_template:#|section:string]
#             #:               a task model id (multiple ids may be added e.g. [1,2,3])
#             debug:           [true|false] print debug info; e.g. prints response items hash (is very verbose)
#             destroy_path:    destroy the path after conversion e.g. does a 'path.destroy'
#                              NOTE: this also deletes the path's path items if the path association includes has_many dependent: :destroy
#                              NOTE: path item version records are created when destroyed
#             component:#      id of a common component to use; default common component with title: 'indented-list'
#             phase_template:# id of the phase template to use; default phase template with name 'two_column_indented_list_observation_list_submit'
#             section:         [string] path's phase component section; default is extracted from the list's phase_template.template
#
#     Typically the component:#, phase_template:# and section options are not needed if the domain data matches the
#     the defaults in the Helpers::PhaseTemplate class.
#
#     The order of the options is not important e.g. for ids 1,2,3 [debug,1,delete_path,2,3]
#
#     The options must can contain id(s) (e.g. digits) and/or keywords (except for 'all' task).
#  
#     The ids correspond to the task's model and are used to select the 'phases' to process.
#       For example:
#         spaces[1]:          all phases in space id 1
#         assignments[1,2,3]: all phases in assignments ids 1, 2 and 3  
#         phases[5,6,7]:      phases ids 5, 6 and 7
#         paths[5,6]:         get phases for path ids 5 and 6 but only process paths 5 and 6
#
#   Examples:
#     rake thinkspace:migrate:diagnostic_paths_to_indented_lists:spaces[1,2]         #=> all phases and paths in space ids 1 and 2
#     rake thinkspace:migrate:diagnostic_paths_to_indented_lists:assignments[1,2]    #=> all phases and paths in assignments 1 and 2
#     rake thinkspace:migrate:diagnostic_paths_to_indented_lists:phases[1,2]         #=> all paths in phases 1 and 2
#     rake thinkspace:migrate:diagnostic_paths_to_indented_lists:paths[1,2]          #=> paths 1 and 2
#     rake thinkspace:migrate:diagnostic_paths_to_indented_lists:all                 #=> all phases and all paths
#
#     rake thinkspace:migrate:diagnostic_paths_to_indented_lists:phases[1,2,destroy_path]
#     rake thinkspace:migrate:diagnostic_paths_to_indented_lists:phases[1,2,debug,phase_template:13,section:new-section]
