module Thinkspace; module Migrate; module DiagnosticPathsToIndentedLists; module Helpers; module RakeProcesses

  # Set the 'phase_scope' based on the rake task and ids in the args.

  attr_reader :phase_scope
  attr_reader :expert_phase_scope

  # ###
  # ### Rake Tasks.
  # ###

  def process_all(args=nil)
    @phase_scope = phase_class.all.order(:id)
    set_additional_options_and_convert(args)
  end

  def process_spaces(args=nil)
    ids = extract_process_ids(args, space_class)
    process_ids_stop_run(:spaces)  if ids.blank?
    spaces           = space_class.where(id: ids)
    phase_ids        = get_spaces_phase_ids(spaces)
    expert_phase_ids = get_spaces_expert_phase_ids(spaces)
    process_common(args, phase_ids)
    process_expert(args, expert_phase_ids)
  end

  def process_assignments(args=nil)
    ids = extract_process_ids(args, assignment_class)
    process_ids_stop_run(:assignments)  if ids.blank?
    assignments      = assignment_class.where(id: ids)
    phase_ids        = get_assignments_phase_ids(assignments)
    expert_phase_ids = get_assignments_expert_phase_ids(assignments)
    process_common(args, phase_ids)
    process_expert(args, expert_phase_ids)
  end

  def process_phases(args=nil)
    ids = extract_process_ids(args, phase_class)
    process_ids_stop_run(:phases)  if ids.blank?
    process_common(args, ids)
    process_expert(args, ids)
  end

  def process_paths(args=nil)
    ids = extract_process_ids(args, path_class)
    process_ids_stop_run(:paths)  if ids.blank?
    @path_ids = ids
    phase_ids = get_paths_phase_ids(ids)
    process_common(args, phase_ids)
  end

  def process_ids_stop_run(model)
    model = model.to_s
    stop_run "Rake task #{model.inspect} required #{model} ids.  Add #{model} ids in the options."
  end

  # ###
  # ### Set: Addition Args, Phase Scope then Call Convert.
  # ###

  def process_common(args, phase_ids)
    stop_run "No phases where selected from the options."  if phase_ids.blank?
    @phase_scope = phase_class.where(id: phase_ids.uniq.sort)
    set_additional_options_and_convert(args)
  end

  def process_expert(args, phase_ids)
    return if phase_ids.blank?
    @expert_phase_scope = phase_class.where(id: phase_ids.uniq.sort)
    convert_expert(args)
  end

  def set_additional_options_and_convert(args)
    @args_string = args.join(',')
    set_list_component_from_args(args)
    set_list_phase_template_from_args(args)
    set_list_phase_component_section_from_args(args)
    set_destroy_path_from_args(args)
    set_debug_from_args(args)
    print_args
    convert_phases_to_indented_lists
  end

  def convert_expert(args)
    print_args
    convert_phases_to_expert_indented_lists
  end

  def set_list_component_from_args(args)
    arg = args.find {|a| a.start_with?('component:')}
    return if arg.blank?
    id        = extract_arg_value(arg)
    component = component_class.find_by(id: id)
    stop_run "Arg common component id #{id} not found."  if component.blank?
    @list_component = component
  end

  def set_list_phase_template_from_args(args)
    arg = args.find {|a| a.start_with?('phase_template:') || a.start_with?('template:')}
    return if arg.blank?
    id             = extract_arg_value(arg)
    phase_template = phase_template_class.find_by(id: id)
    stop_run "Arg phase template id #{id} not found."  if phase_template.blank?
    @list_phase_template = phase_template
  end

  def set_list_phase_component_section_from_args(args)
    arg = args.find {|a| a.start_with?('section:')}
    return if arg.blank?
    @list_phase_component_section = extract_arg_value(arg)
  end

  def set_destroy_path_from_args(args)
    arg = args.find {|a| a == 'destroy_path' || a == 'destroy-path'}
    return if arg.blank?
    @destroy_path = true
  end

  def set_debug_from_args(args)
    arg = args.find {|a| a == 'debug'}
    return if arg.blank?
    @debug = true
  end

  # ###
  # ### Scope Helpers.
  # ###

  def get_spaces_phase_ids(spaces)
    phase_ids = Array.new
    spaces.each do |space|
      phase_ids += get_assignments_phase_ids(space.thinkspace_casespace_assignments)
    end
    phase_ids
  end

  def get_assignments_phase_ids(assignments)
    phase_ids = Array.new
    assignments.each do |assignment|
      phases      = assignment.thinkspace_casespace_phases
      path_phases = phases.joins(:thinkspace_casespace_phase_components).where('thinkspace_casespace_phase_components.componentable_type = ?', path_class.name)
      phase_ids   += path_phases.pluck(:id)
    end
    phase_ids
  end

  def get_spaces_expert_phase_ids(spaces)
    phase_ids = Array.new
    spaces.each do |space|
      phase_ids += get_assignments_expert_phase_ids(space.thinkspace_casespace_assignments)
    end
    phase_ids
  end

  def get_assignments_expert_phase_ids(assignments)
    phase_ids = Array.new
    assignments.each do |assignment|
      phases      = assignment.thinkspace_casespace_phases
      path_phases = phases.joins(:thinkspace_casespace_phase_components).where('thinkspace_casespace_phase_components.componentable_type = ?', path_viewer_class.name)
      phase_ids   += path_phases.pluck(:id)
    end
    phase_ids
  end

  def get_paths_phase_ids(path_ids)
    paths     = path_class.where(id: path_ids)
    phase_ids = Array.new
    paths.each do |path|
      phase = path.authable
      stop_run "Path authable is not a phase #{path.inspect} but is #{phase.inspect}."  unless phase.is_a?(phase_class)
      phase_ids.push(phase.id)
    end
    phase_ids
  end

  # ###
  # ### Helpers.
  # ###

  def extract_process_ids(args, klass)
    ids = args.select {|a| is_digits?(a)}
    return nil if ids.blank?
    ids = ids.map {|id| id.to_i}
    validate_ids(klass, ids)
  end

  def validate_ids(klass, ids)
    ids.each do |id|
      record = klass.find_by(id: id)
      stop_run "Record '#{klass.name}.#{id}' not found."  if record.blank?
    end
    ids
  end

  def extract_arg_value(arg)
    return nil if arg.blank?
    val = arg.split(':',2).last
    val.blank? ? nil : val.to_s.strip
  end

  def is_digits?(arg)
    return false if arg.blank?
    arg.match(/^\d+$/)
  end

  def print_args
    hash                           = Hash.new
    hash[:arg_string]              = @args_string
    hash[:destroy_path]            = @destroy_path
    hash[:debug]                   = @debug
    hash[:component]               = "#{@list_component.id} (#{@list_component.title})"  if @list_component.present?
    hash[:phase_template]          = "#{@list_phase_template.id} (#{@list_phase_template.name})"  if @list_phase_template.present?
    hash[:phase_component_section] = @list_phase_component_section  if @list_phase_component_section.present?
    hash[:path_ids]                = @path_ids                      if @path_ids.present?
    hash[:phase_ids]               = phase_scope.map(&:id)
    print_hash(hash)
  end

end; end; end; end; end
