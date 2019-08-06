module Thinkspace; module PeerAssessment; module Shared; module Helpers
  extend ::ActiveSupport::Concern
  
  # Helpers
  def row_for_record(sheet, record)
    type  = record.class.name.split('::').pop
    klass = "Thinkspace::PeerAssessment::Rows::#{type}"
    klass = klass.safe_constantize
    raise "Rows class not found for type [#{type}]." unless klass
    klass.new(sheet, record)
  end

  # # Classes
  def assessment_class; Thinkspace::PeerAssessment::Assessment; end
  def team_set_class; Thinkspace::PeerAssessment::TeamSet; end
  def review_set_class; Thinkspace::PeerAssessment::ReviewSet; end
  def review_class; Thinkspace::PeerAssessment::Review; end

  def assignment_class; Thinkspace::Casespace::Assignment; end
  def phase_class; Thinkspace::Casespace::Phase; end
  def phase_component_class; Thinkspace::Casespace::PhaseComponent; end

  def user_class;  Thinkspace::Common::User; end
  def space_class; Thinkspace::Common::Space; end
  def space_user_class; Thinkspace::Common::SpaceUser; end

  def team_class; Thinkspace::Team::Team; end
  def team_user_class; Thinkspace::Team::TeamUser; end
  
end; end; end; end
