module Thinkspace; module Migrate; module ToComponents
  class Helper < Totem::DbMigrate::BaseHelper

    def before_all(*args)
      PaperTrail.enabled = false
      delete_all_new_class_records!(new_paper_trail_version_class)
      delete_all_new_class_records!(new_phase_template_class)
      create_phase_templates
      @max_allowed_missing_phase_states_for_phase_scores = 3
      @num_allowed_missing_phase_states_for_phase_scores = 0
    end

    def after_all(*args)
    end

    def before_create_thinkspace_common_space_types(config, old_space_type, attributes)
      # Change the lookup_model for assignments.
      case attributes[:lookup_model]
      when old_class_name(old_assignment_class).underscore.pluralize
        attributes[:lookup_model] = new_assignment_class.name.underscore.pluralize
        ignore_record_columns(:lookup_model)
      end
    end

    def before_create_thinkspace_casespace_phases(config, old_phase, attributes)
      #=> added:   [team_category_id]
      #=> removed: [team_based]
      attributes[:team_category_id]  = get_phase_team_category_id(old_phase)
      attributes[:phase_template_id] = get_new_phase_template_id_for_old_phase(old_phase)
      ignore_record_columns(:phase_template_id)
    end

    def before_create_thinkspace_casespace_phase_scores(config, old_score, attributes)
      #=> added:   [phase_state_id]
      #=> removed: [ownerable_id, ownerable_type, phase_id]
      phase_state = old_phase_state_class.find_by(
        ownerable_type: old_score.ownerable_type,
        ownerable_id:   old_score.ownerable_id,
        phase_id:       old_score.phase_id,
      )
      if phase_state.blank?
        over_max = (@num_allowed_missing_phase_states_for_phase_scores += 1) > @max_allowed_missing_phase_states_for_phase_scores
        raise_error "Phase state not found for phase score #{old_score.inspect}."  if over_max
        skip_create  # skip creating the record since model validations require a phase_state_id
      else
        attributes[:phase_state_id] = phase_state.id
      end
    end

    def before_create_thinkspace_diagnostic_path_viewer_viewers(config, old_record, attributes)
      #=> added:   [authable_id, authable_type, ownerable_id, ownerable_type]
      path = old_diagnostic_path_class.find_by(id: old_record.path_id)
      raise_error "Path not found for diagnostic path viewer #{old_record.inspect}."  if path.blank?
      phase = old_phase_class.find_by(id: path.phase_id)
      raise_error "Phase not found for diagnostic path viewer #{old_record.inspect}."  if phase.blank?
      attributes[:authable_type]  = old_phase_class.name
      attributes[:authable_id]    = phase.id
      attributes[:ownerable_type] = old_user_class.name
      attributes[:ownerable_id]   = old_record.user_id
    end

    def before_create_thinkspace_html_contents(config, old_record, attributes)
      #=> added:   [html_content]
      #=> removed: [tool_content, view_generator]
      attributes[:html_content] = attributes[:tool_content]
    end

    def before_create_thinkspace_input_element_elements(config, old_record, attributes)
      #=> added:   [componentable_id, componentable_type]
      #=> removed: [helper_embedable_id, helper_embedable_type]
      attributes[:componentable_id]   = attributes[:helper_embedable_id]
      attributes[:componentable_type] = attributes[:helper_embedable_type]
    end

    def before_create_thinkspace_team_teams(config, old_team, attributes)
      # Fix teams without an authable.  Set to the team.teamable.
      if attributes[:authable_type].blank?
        teamable                   = old_team_teamable_class.find_by(team_id: old_team.id)
        raise_error "Old team id #{old_team.id} does not have an authable or a teamable."  if teamable.blank?
        attributes[:authable_type] = teamable.teamable_type
        attributes[:authable_id]   = teamable.teamable_id
        ignore_record_columns(:authable_type, :authable_id)
      end
    end

    def before_create_thinkspace_artifact_files(config, old_file, attributes)
      # Fix files without an ownerable.
      return if old_file.ownerable_type.present?
      attributes[:ownerable_type] = polymorphic_type(old_user_class)
      attributes[:ownerable_id]   = old_file.user_id
      ignore_record_columns(:ownerable_type, :ownerable_id)
    end

    def before_create_thinkspace_observation_list_lists(config, old_list, attributes)
      # Can only fix 1 of 3 blank authables (2 do not have a phase tool helper record).
      return if old_list.authable_type.present?
      phase_tool_helper = old_phase_tool_helper_class.find_by(helperable_type: polymorphic_type(old_list), helperable_id: old_list.id)
      if phase_tool_helper.present?
        phase_tool = old_phase_tool_class.find_by(id: phase_tool_helper.phase_tool_id)
        if phase_tool.present?
          phase = old_phase_class.find_by(id: phase_tool.phase_id)
          attributes[:authable_type] = polymorphic_type(old_phase_class)
          attributes[:authable_id]   = phase.id
          ignore_record_columns(:authable_type, :authable_id)
        end
      end
    end

    # ###
    # ### Get Phase Team.
    # ###

    def get_phase_team_category_id(old_phase)
      case
      when old_phase.team_based?  # old model had 'team_based = true' only for collaboration teams
        new_collaboration_team_category.id
      when old_phase_has_peer_review_teams?(old_phase)
        new_peer_review_team_cateogory.id
      else
        nil
      end
    end

    def old_phase_has_peer_review_teams?(old_phase)
      return false if old_phase.team_based?
      return true  if old_team_teamable_class.find_by(teamable_id: old_phase.id, teamable_type: polymorphic_type(old_phase))
      return true  if old_team_teamable_class.find_by(teamable_id: old_phase.assignment_id, teamable_type: polymorphic_type(old_assignment_class))
      false
    end

    # ###
    # ### Helpers.
    # ###

    def get_old_configuration(old_record)
      old_configuration_class.find_by(configurable_id: old_record.id, configurable_type: polymorphic_type(old_record))
    end

    # ###
    # ### OLD Model Classes.
    # ###
    def old_user_class;                     get_old_model_class('thinkspace/common/user'); end
    def old_configuration_class;            get_old_model_class('thinkspace/common/configuration'); end
    def old_assignment_class;               get_old_model_class('thinkspace/wips/casespace/assignment'); end
    def old_phase_class;                    get_old_model_class('thinkspace/wips/casespace/phase'); end
    def old_phase_state_class;              get_old_model_class('thinkspace/wips/casespace/phase_state'); end
    def old_phase_score_class;              get_old_model_class('thinkspace/wips/casespace/phase_score'); end
    def old_phase_template_class;           get_old_model_class('thinkspace/wips/casespace/phase_template'); end
    def old_phase_tool_class;               get_old_model_class('thinkspace/wips/casespace/phase_tool'); end
    def old_phase_tool_helper_class;        get_old_model_class('thinkspace/wips/casespace/phase_tool_helper'); end
    def old_phase_tool_helper_embed_class;  get_old_model_class('thinkspace/wips/casespace/phase_tool_helper_embed'); end
    def old_phase_template_section_class;   get_old_model_class('thinkspace/wips/casespace/phase_template_section'); end


    def old_artifact_bucket_class;     get_old_model_class('thinkspace/tools/artifact/bucket'); end
    def old_html_content_class;        get_old_model_class('thinkspace/tools/html/content'); end
    def old_diagnostic_path_class;     get_old_model_class('thinkspace/tools/diagnostic_path/path'); end
    def old_observation_list_class;    get_old_model_class('thinkspace/tools/helpers/observation_list/list'); end
    def old_input_element_class;       get_old_model_class('thinkspace/tools/helper_embeds/input_element/element'); end

    def old_team_class;                get_old_model_class('thinkspace/team/team'); end
    def old_team_teamable_class;       get_old_model_class('thinkspace/team/team_teamable'); end

    # ###
    # ### NEW Model Classes.
    # ###
    def new_user_class;                get_new_model_class('thinkspace/common/user'); end
    def new_assignment_class;          get_new_model_class('thinkspace/casespace/assignment'); end
    def new_phase_class;               get_new_model_class('thinkspace/casespace/phase'); end
    def new_phase_component_class;     get_new_model_class('thinkspace/casespace/phase_component'); end
    def new_phase_template_class;      get_new_model_class('thinkspace/casespace/phase_template'); end
    def new_team_category_class;       get_new_model_class('thinkspace/team/team_category'); end

    def new_paper_trail_version_class; get_new_model_class('paper_trail/version'); end

    def new_collaboration_team_category; @new_collaboration_team_category ||= new_team_category_class.collaboration; end
    def new_peer_review_team_cateogory;  @new_peer_review_team_category   ||= new_team_category_class.peer_review; end

    # ###
    # ### Phase Templates.
    # ###

    def get_new_phase_template_id_for_old_phase(old_phase)
      phase_template_id = old_phase.phase_template_id
      phase_tools       = old_phase_tool_class.where(phase_id: old_phase.id)

      case

      when phase_template_id == 1
        case
        when phase_tools.length == 1
          name = get_new_phase_template_one_column_name(old_phase, phase_tools.first)
        when phase_tools.length == 2
          name = :one_column_html_artifact_submit
        else
          raise_error "Unknown new phase template for phase template id 1."
        end

      when phase_template_id == 2
        phase_tool_ids = phase_tools.map(&:id)
        phase_helpers  = old_phase_tool_helper_class.where(phase_tool_id: phase_tool_ids)
        raise_error "More than one phase helper for old phase #{phase_helpers.inspect}."  if phase_helpers.length > 1
        phase_helper = phase_helpers.first
        types = phase_tools.map(&:toolable_type)
        types.push(phase_helper.helperable_type) if phase_helper.present?
        name = get_new_phase_template_two_column_name(old_phase, types)

      when phase_template_id == 3
        name = :one_column_html_submit  # default any sandbox phases

      else
        raise_error "Unknown phase template id #{phase_template_id} for old phase #{old_phase.inspect}"
      end
      raise_error "Could not find new phase template for phase template id #{phase_template_id}."  if name.blank?
      phase_template = new_phase_templates_name_map[name]
      raise_error "No new phase template found for name #{name.to_s.inspect}."  if phase_template.blank?
      phase_template.id
    end

    def get_new_phase_template_one_column_name(old_phase, phase_tool)
      section_id = phase_tool.phase_template_section_id
      raise_error "Unknown one column phase template section id #{section_id}"  unless section_id == 2
      case phase_tool.toolable_type
      when polymorphic_type(old_html_content_class)
        old_phase_has_submit?(old_phase) ? :one_column_html_submit : :one_column_html_no_submit
      when polymorphic_type(old_artifact_bucket_class)
        :one_column_artifact_submit
      else
        raise_error "Did not find one column phase template for phase tool type #{phase_tool.toolable_type.inspect}."
      end
    end

    def get_new_phase_template_two_column_name(old_phase, types)
      html = polymorphic_type(old_html_content_class)
      list = polymorphic_type(old_observation_list_class)
      path = polymorphic_type(old_diagnostic_path_class)
      case types
      when [html, html]   then :two_column_html_html_submit
      when [html, list]   then :two_column_html_observation_list_submit
      when [path, list]   then :two_column_diagnostic_path_observation_list_submit
      else
        raise_error "Did not find two column phase template for phase tools/helpers with types #{types}."
      end
    end

    def old_phase_has_submit?(old_phase)
      configuration = get_old_configuration(old_phase)
      return true if configuration.blank?  # default to true
      configuration = configuration.attributes.with_indifferent_access
      settings      = configuration[:settings] || Hash.new
      submit        = settings[:submit] || Hash.new
      !(submit[:visible] == false)
    end

    # ######################################################################################
    # ###
    # ### Create NEW Phase Templates (:before_all).
    # ###

    attr_reader :new_phase_templates_name_map

    def create_phase_templates
      @new_phase_templates_name_map = Hash.new
      phase_template_one_column_html_submit
      phase_template_one_column_html_no_submit
      phase_template_one_column_html_artifact_submit
      phase_template_one_column_artifact_submit
      phase_template_two_column_html_html_submit
      phase_template_two_column_html_observation_list_submit
      phase_template_two_column_diagnostic_path_observation_list_submit
      phase_template_two_column_diagnostic_path_viewer_diagnostic_path_viewer_ownerable
      phase_template_two_column_lab_observation_list_submit
    end

    def phase_template_one_column_html_submit
      # 4. count:   502 -> section: 2 r-1-c-1  tools: [:content] submit: true   phase_template_id: 1
      name            = :one_column_html_submit
      hash            = Hash.new
      hash[:title]    = 'One Column HTML with Submit'
      hash[:template] = <<-TEND
        #{casespace_phase_header}
        <row>
          <column>
            <component section='html' title='html'/>
          </column>
        </row>
        #{casespace_phase_submit}
      TEND
      new_phase_templates_name_map[name] = create_phase_template(hash.merge(name: name))
    end

    def phase_template_one_column_html_no_submit
      # 3. count:     3 -> section: 2 r-1-c-1  tools: [:content] submit: false  phase_template_id: 1
      name            = :one_column_html_no_submit
      hash            = Hash.new
      hash[:title]    = 'One Column HTML without Submit'
      hash[:template] = <<-TEND
        #{casespace_phase_header}
        <row>
          <column>
            <component section='html' title='html'/>
          </column>
        </row>
      TEND
      new_phase_templates_name_map[name] = create_phase_template(hash.merge(name: name))
    end

    def phase_template_one_column_html_artifact_submit
      # 2. count:    16 -> section: 2 r-1-c-1  tools: [:content, :bucket] submit: true   phase_template_id: 1
      name            = :one_column_html_artifact_submit
      hash            = Hash.new
      hash[:title]    = 'One Column HTML and Artifact with Submit'
      hash[:template] = <<-TEND
        #{casespace_phase_header}
        <row>
          <column>
            <component section='html' title='html'/>
            <component section='artifact' title='artifact-bucket'/>
          </column>
        </row>
        #{casespace_phase_submit}
      TEND
      new_phase_templates_name_map[name] = create_phase_template(hash.merge(name: name))
    end

    def phase_template_one_column_artifact_submit
      # 1. count:   140 -> section: 2 r-1-c-1  tools: [:bucket] submit: true   phase_template_id: 1
      name            = :one_column_artifact_submit
      hash            = Hash.new
      hash[:title]    = 'One Column Artifact with Submit'
      hash[:template] = <<-TEND
        #{casespace_phase_header}
        <row>
          <column>
            <component section='artifact' title='artifact-bucket'/>
          </column>
        </row>
        #{casespace_phase_submit}
      TEND
      new_phase_templates_name_map[name] = create_phase_template(hash.merge(name: name))
    end

    def phase_template_two_column_html_html_submit
      # 5. count:   464 -> section: 4 r-1-c-1  tools: [:content]  section: 5 r-1-c-2  tools: [:content] submit: true   phase_template_id: 2
      name            = :two_column_html_html_submit
      hash            = Hash.new
      hash[:title]    = 'Two column HTML and HTML with Submit'
      hash[:template] = <<-TEND
        #{casespace_phase_header}
        <row>
          <column width=8>
            <component section='html-1' title='html'/>
            #{casespace_phase_submit}
          </column>
          <column width=4>
            <component section='html-2' title='html'/>
          </column>
        </row>
      TEND
      new_phase_templates_name_map[name] = create_phase_template(hash.merge(name: name))
    end

    def phase_template_two_column_html_observation_list_submit
      # 6. count: 13 -> section: 4 r-1-c-1  tools: [:content] section: 5 r-1-c-2  tools: [:list] submit: true   phase_template_id: 2
      name            = :two_column_html_observation_list_submit
      hash            = Hash.new
      hash[:title]    = 'Two column HTML and Observation List with Submit'
      hash[:template] = <<-TEND
        <row>
          <column width=8>
            #{casespace_phase_header}
            <component section='html' title='html-select-text' select-text='obs-list'/>
            #{casespace_phase_submit}
          </column>
          <column width=4>
            <component section='obs-list' title='observation-list'/>
          </column>
        </row>
      TEND
      new_phase_templates_name_map[name] = create_phase_template(hash.merge(name: name))
    end


    def phase_template_two_column_diagnostic_path_observation_list_submit
      # 7. count: 6 -> section: 4 r-1-c-1  tools: [:path] section: 5 r-1-c-2  tools: [:list] submit: true   phase_template_id: 2
      name            = :two_column_diagnostic_path_observation_list_submit
      hash            = Hash.new
      hash[:title]    = 'Two column Diagnostic Path and Observation List with Submit'
      hash[:template] = <<-TEND
        <row>
          <column width=8>
            #{casespace_phase_header}
            <component section='diag-path' title='diagnostic-path' source='obs-list'/>
            #{casespace_phase_submit}
          </column>
          <column width=4>
            <component section='obs-list' title='observation-list' droppable='false'/>
          </column>
        </row>
      TEND
      new_phase_templates_name_map[name] = create_phase_template(hash.merge(name: name))
    end

    def phase_template_two_column_diagnostic_path_viewer_diagnostic_path_viewer_ownerable
      # 8. new (migrate assignments)
      name            = :two_column_diagnostic_path_viewer_diagnostic_path_viewer_ownerable
      hash            = Hash.new
      hash[:title]    = 'Two column Diagnostic Path Viewer and Diagnostic Path Ownerable Viewer with Submit'
      hash[:template] = <<-TEND
        <row><column><component section='header' title='casespace-phase-header'/></column></row>
        <row>
          <column width=6>
            <component section='html-viewer' title='html'/>
          </column>
          <column width=6>
            <component section='html-ownerable' title='html'/>
          </column>
        </row>
        <row>
          <column width=6>
            <component section='diag-path-viewer' title='diagnostic-path-viewer'/>
          </column>
          <column width=6>
            <component section='diag-path-viewer-ownerable' title='diagnostic-path-viewer-ownerable'/>
          </column>
        </row>
        <row><column><component section='submit' title='casespace-phase-submit' data-actions='{"submit":"submit"}'/></column></row>
      TEND
      new_phase_templates_name_map[name] = create_phase_template(hash.merge(name: name))
    end

    def phase_template_two_column_lab_observation_list_submit
      # 9. new (migrate assignments)
      name            = :two_column_lab_observation_list_submit
      hash            = Hash.new
      hash[:title]    = 'Two column Lab and Observation List with Submit'
      hash[:template] = <<-TEND
        <row>
          <column width=8>
            #{casespace_phase_header}
            <component section='chart' title='lab'/>
            #{casespace_phase_submit}
          </column>
          <column width=4>
            <component section='obs-list' title='observation-list' droppable='false'/>
          </column>
        </row>
      TEND
      new_phase_templates_name_map[name] = create_phase_template(hash.merge(name: name))
    end

    def casespace_phase_header
      html = <<-TEND
        <row><column><component section='header' title='casespace-phase-header'/></column></row>
      TEND
      html.strip
    end

    def casespace_phase_submit
      html = <<-TEND
        <row><column><component section='submit' title='casespace-phase-submit' data-actions='{"submit":"submit"}'/></column></row>
      TEND
      html.strip
    end

    def create_phase_template(hash)
      hash[:domain]  = true  unless hash.has_key?(:domain)
      phase_template = new_phase_template_class.create(hash)
      if phase_template.errors.present?
        raise_error "Could not save new phase template.  Validation errors: #{phase_template.errors.messages}."
      end
      phase_template
    end

  end # class

end; end; end
