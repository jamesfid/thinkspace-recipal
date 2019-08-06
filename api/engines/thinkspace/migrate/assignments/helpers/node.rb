module Thinkspace; module Migrate; module Assignments; module Helpers
  module Node

    def get_node_id(node)
      id = node.attribute('_id')
      id.present? ? id.text : nil
    end

    def get_node_value(node, attribute)
      value = node.attribute(attribute.to_s)
      value.present? ? value.text : nil
    end

    def find_node_value(node, attribute)
      value = node.css(attribute.to_s)
      value.present? ? value.text : nil
    end

    def find_node(node, attribute)
      value = node.css(attribute.to_s)
      value.present? ? value : nil
    end

    attr_reader :current_phase_node  # required to be set for the 'get_phase...' methods to work.

    def get_phase_node_value(attribute); get_node_value(current_phase_node, attribute); end

    def get_phase_id;            get_node_id(current_phase_node); end
    def get_phase_type;          get_phase_node_value(:type); end
    def get_phase_title;         get_phase_node_value(:name); end
    def get_phase_sub_score;     get_phase_node_value(:subScore); end
    def get_phase_default_state; get_phase_node_value(:isEnabled) == 'true' ? 'unlocked' : 'locked'; end

    def get_phase_team_category_id
      return nil unless get_phase_node_value(:peerReview) == 'true'
      print_debug "Phase has peer review team", ids: true
      category = Thinkspace::Team::TeamCategory.peer_review
      raise_error "Peer review team category not found."  if category.blank?
      category.id
    end

    def get_phase_item_type
      type = get_phase_node_value(:itemType)
      type.blank? || type == 'null' ? nil : type
    end

    def get_phase_template_id
      name           = get_phase_template_name
      phase_template = Thinkspace::Casespace::PhaseTemplate.find_by(name: name)
      raise_error "Phase template name #{name.inspect} not found."  if phase_template.blank?
      phase_template.id
    end

    def get_phase_template_name
      case get_phase_type
      when 'content-items'  then :two_column_html_observation_list_submit
      when 'labtest'        then :two_column_lab_observation_list_submit
      when 'diagnosticpath' then :two_column_diagnostic_path_observation_list_submit
      when 'content'        then :one_column_html_submit
      when 'expertpath'     then :two_column_diagnostic_path_viewer_diagnostic_path_viewer_ownerable
      else
        raise_error "Unknown phase template for type #{type.inspect} in #{current_assignment_path.inspect}."
      end
    end

  end

end; end; end; end
