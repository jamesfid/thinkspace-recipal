module Thinkspace; module Migrate; module ToComponents; module Make
  class PhaseComponents < Totem::DbMigrate::BaseHelper

# Phase Templates Required:
#  1. count:   140 -> section: 2 r-1-c-1  tools: [:bucket]             submit: true   phase_template: 1
#  2. count:    16 -> section: 2 r-1-c-1  tools: [:content, :bucket]   submit: true   phase_template: 1
#  3. count:     3 -> section: 2 r-1-c-1  tools: [:content]            submit: false  phase_template: 1
#  4. count:   502 -> section: 2 r-1-c-1  tools: [:content]            submit: true   phase_template: 1
#  5. count:   464 -> section: 4 r-1-c-1  tools: [:content] section: 5 r-1-c-2  tools: [:content]  submit: true   phase_template: 2
#  6. count:    13 -> section: 4 r-1-c-1  tools: [:content] section: 5 r-1-c-2  tools: [:list]     submit: true   phase_template: 2
#  7. count:     6 -> section: 4 r-1-c-1  tools: [:path]    section: 5 r-1-c-2  tools: [:list]     submit: true   phase_template: 2
#            -----
# total:      1144
#
# header    = 1144 (all)
# html      = 534 (16 + 3 + 502 + 13)
# submit    = 1141 (1144 - 3 with submit=false)
# obs-list  = 19 (13 + 6)
# html-1    = 464
# html-2    = 464
# artifact  = 156 (140 + 16)
# diag_path = 6

    require 'nokogiri'

    attr_reader :phase_template_component_map

    def process
      delete_all_new_class_records!(new_common_component_class)
      delete_all_new_class_records!(new_phase_component_class)
      create_all_common_components
      @comp_counts = Hash.new(0)
      map_phase_template_components
      add_phase_components
      puts "\n"
      puts "Phase template section's phase components created:"
      pp @comp_counts
      puts "\n"
    end

    def map_phase_template_components
      @phase_template_component_map = Hash.new
      new_phase_template_class.all.each do |phase_template|
        phase_template_component_map[phase_template.id] = parse_phase_template(phase_template)
      end
    end

    def add_phase_components
      new_phase_class.all.each do |phase|
        sections = phase_template_component_map[phase.phase_template_id]
        raise_error "Phase template sections blank.", phase if sections.blank?
        sections.each do |section, attrs|
          add_phase_component_for_section(phase, section, attrs)
        end
      end
    end

    def add_phase_component_for_section(phase, section, attrs)
      case section
      when 'header'                       then create_phase_componentable_component(phase, section, attrs)
      when 'html', 'html-1', 'html-2'     then create_html_component(phase, section, attrs)
      when 'artifact'                     then create_artifact_component(phase, section, attrs)
      when 'obs-list'                     then create_observation_list_component(phase, section, attrs)
      when 'diag-path'                    then create_diagnostic_path_component(phase, section, attrs)
      when 'submit'                       then create_phase_componentable_component(phase, section, attrs)
      else
        raise_error "Unknown section name #{section.inspect} in phase_template id #{phase.phase_template_id}.", phase
      end
    end

    # ###
    # ### Componentables.
    # ###

    def create_phase_componentable_component(phase, section, attrs)
      create_phase_component(phase, section, phase, attrs)
    end

    def create_html_component(phase, section, attrs)
      scope  = new_html_content_class.where(authable: phase).order(:id)
      scopes = []
      scope.each do |html|
        phase_tool                = old_phase_tool_class.find_by(toolable_id: html.id, toolable_type: polymorphic_type(old_html_content_class))
        puts "[ERROR] No phase tool found for toolable: #{polymorphic_type(old_html_content_class)}" unless phase_tool.present?
        phase_template_section_id = phase_tool.phase_template_section_id
        phase_template_section    = old_phase_template_section_class.find_by(id: phase_template_section_id)
        order                     = phase_template_section.template_section_order
        scopes[order]             = html
      end
      scopes.compact!
      count = scopes.length
      case
      when count == 1 && section == 'html'
        create_phase_component(phase, section, scopes.first, attrs)
      when count == 2 && section == 'html-1'
        create_phase_component(phase, section, scopes.first, attrs)
      when count == 2 && section == 'html-2'
        create_phase_component(phase, section, scopes.last, attrs)
      else
        raise_error "Unknown section #{section.inspect} with html content count #{count}.", phase
      end
    end

    def create_artifact_component(phase, section, attrs)
      scope = new_artifact_bucket_class.where(authable: phase).order(:id)
      count = scope.count
      case
      when count == 1
        create_phase_component(phase, section, scope.first, attrs)
      else
        raise_error "Unknown section #{section.inspect} with artifact bucket count #{count}.", phase
      end
    end

    def create_observation_list_component(phase, section, attrs)
      scope = new_observation_list_class.where(authable: phase).order(:id)
      count = scope.count
      case
      when count == 1
        create_phase_component(phase, section, scope.first, attrs)
      else
        raise_error "Unknown section #{section.inspect} with observation list count #{count}.", phase
      end
    end

    def create_diagnostic_path_component(phase, section, attrs)
      scope = new_diagnostic_path_class.where(authable: phase).order(:id)
      count = scope.count
      case
      when count == 1
        create_phase_component(phase, section, scope.first, attrs)
      else
        raise_error "Unknown section #{section.inspect} with diagnostic path count #{count}.", phase
      end
    end

    def create_phase_component(phase, section, componentable, attrs)
      @comp_counts[section] += 1
      comp            = get_common_component(attrs['title'])
      phase_component = new_phase_component_class.create(
        phase_id:      phase.id,
        section:       section,
        component_id:  comp.id,
        componentable: componentable
      )
      raise_error "Create phase component error #{attrs.inspect}.  Phase component is blank." if phase_component.blank?
      raise_error "Create phase component error #{attrs.inspect}.  Validation errors: #{phase_component.errors.messages}." if phase_component.errors.present?
      phase_component
    end

    def get_common_component(title)
      raise_error "Component #{new_common_component_class.name.inspect} title blank."  if title.blank?
      component = new_common_component_class.find_by(title: title)
      raise_error "Component #{new_common_component_class.name.inspect} with title #{title.inspect} not found."  if component.blank?
      component
    end

    # ###
    # ### NEW Model Classes.
    # ###

    def new_common_component_class;    get_new_model_class('thinkspace/common/component'); end
    def new_phase_class;               get_new_model_class('thinkspace/casespace/phase'); end
    def new_phase_component_class;     get_new_model_class('thinkspace/casespace/phase_component'); end
    def new_phase_template_class;      get_new_model_class('thinkspace/casespace/phase_template'); end

    def new_artifact_bucket_class;     get_new_model_class('thinkspace/artifact/bucket'); end
    def new_html_content_class;        get_new_model_class('thinkspace/html/content'); end
    def new_diagnostic_path_class;     get_new_model_class('thinkspace/diagnostic_path/path'); end
    def new_observation_list_class;    get_new_model_class('thinkspace/observation_list/list'); end

    # ###
    # ### Helpers.
    # ###

    def parse_phase_template(phase_template)
      hash       = Hash.new
      html       = Nokogiri::HTML.fragment(phase_template.template)
      components = html.css('component')
      components.each do |component|
        comp          = Hash.from_xml(component.to_s)['component'] || Hash.new
        section       = comp['section'] || comp['title']  # totem-template-manager will default the section to the title
        hash[section] = comp
      end
      hash
    end

    def raise_error(message, phase=nil)
      super message  if phase.blank?
      message = "Phase id: #{phase.id.to_s.rjust(5)} - " + message
      debug_errors(phase)
      super message
    end

    def debug_errors(phase)
      old_phase_tools   = old_phase_tool_class.where(phase_id: phase.id)
      phase_tool_ids    = old_phase_tools.map(&:id)
      old_phase_helpers = old_phase_tool_helper_class.where(phase_tool_id: phase_tool_ids)
      pp old_phase_tools
      pp old_phase_helpers
    end

    def old_phase_class;                    get_old_model_class('thinkspace/wips/casespace/phase'); end
    def old_phase_template_class;           get_old_model_class('thinkspace/wips/casespace/phase_template'); end
    def old_phase_template_section_class;   get_old_model_class('thinkspace/wips/casespace/phase_template_section'); end
    def old_phase_tool_class;               get_old_model_class('thinkspace/wips/casespace/phase_tool'); end
    def old_phase_tool_helper_class;        get_old_model_class('thinkspace/wips/casespace/phase_tool_helper'); end
    def old_html_content_class;             get_old_model_class('thinkspace/tools/html/content'); end


    # ########################################################## #
    # ### Common Components Seed ############################### #
    # ########################################################## #

    def create_all_common_components
      create_common_component(
        title:       'artifact-bucket',
        description: '',
        value:       {
          path: [:artifact, :bucket]
        },
      )
      create_common_component(
        title:       'casespace-phase-header',
        description: '',
        value:       {
          path: [:casespace, :phase, :header]
        },
      )
      create_common_component(
        title:       'casespace-phase-submit',
        description: '',
        value:       {
          path: [:casespace, :phase, :submit]
        },
      )
      create_common_component(
        title:       'diagnostic-path-viewer',
        description: '',
        value:       {
          path: [:diagnostic_path_viewer, :viewer]
        },
      )
      create_common_component(
        title:       'diagnostic-path-viewer-ownerable',
        description: '',
        value:       {
          path: [:diagnostic_path_viewer, :viewer_ownerable]
        },
      )
      create_common_component(
        title:       'diagnostic-path',
        description: '',
        value:       {
          path: [:diagnostic_path, :path]
        },
      )
      create_common_component(
        title:       'html',
        description: '',
        value:       {
          path: [:html, :html]
        },
        preprocessors: input_element_html_preprocessors(responses: true, carry_forward: true)
      )
      create_common_component(
        title:       'html-only',
        description: '',
        value:       {
          path: [:html, :html_only]
        },
      )
      create_common_component(
        title:       'html-select-text',
        description: '',
        value:       {
          path: [:html, :html_select_text]
        },
        preprocessors: input_element_html_preprocessors(responses: true, carry_forward: true)
      )
      create_common_component(
        title:       'lab',
        description: '',
        value:       {
          path: [:lab, :lab]
        },
      )
      create_common_component(
        title:      'observation-list',
        description: '',
        value:      {
          path: [:observation_list, :list]
        },
      )
      create_common_component(
        title:       'weather-forecaster',
        description: 'Weather Forecaster Assessment',
        value:       {
          path: [:weather_forecaster, :assessment]
        },
      )
      create_common_component(
        title:       'peer-assessment',
        description: 'Peer Assessment',
        value:       {
          path: [:peer_assessment, :assessment]
        },
      )
      create_common_component(
        title:       'peer-assessment-overview',
        description: 'Anonymized peer assessment overviews.',
        value:       {
          path: [:peer_assessment, :overview]
        },
      )
      create_common_component(
        title:       'simulation',
        description: 'Simulation Render',
        value:       {
          path: [:simulation, :simulation]
        },
      )
    end

    def input_element_html_preprocessors(*args)
      options   = args.extract_options!
      attribute = options[:attribute] || 'html_content'
      paths     = Array.new
      paths.push [:input_element, :preprocessors, :responses]      if options[:responses] == true
      paths.push [:input_element, :preprocessors, :carry_forward]  if options[:carry_forward] == true
      [{attribute: attribute, paths: paths}]
    end

    def create_common_component(hash)
      comp = new_common_component_class.create(hash)
      raise_error "Create common component error #{hash.inspect}.  Component is blank." if comp.blank?
      raise_error "Create common component error #{hash.inspect}.  Validation errors: #{comp.errors.messages}." if comp.errors.present?
      comp
    end

  end
  
end; end; end; end
