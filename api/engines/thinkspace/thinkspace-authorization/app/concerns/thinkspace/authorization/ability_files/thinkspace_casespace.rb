module Thinkspace; module Authorization
class ThinkspaceCasespace < ::Totem::Settings.authorization.platforms.thinkspace.cancan.classes.ability_engine

  def process; call_private_methods; end

  protected

  def read_assignment;  {space_id: read_space_ids}.merge(read_states); end
  def admin_assignment; {space_id: admin_space_ids}.merge(admin_states); end

  def read_phase;  {thinkspace_casespace_assignment: read_assignment}.merge(read_states);  end
  def admin_phase; {thinkspace_casespace_assignment: admin_assignment}.merge(admin_states); end

  def read_phase_association;  {thinkspace_casespace_phase: read_phase};  end
  def admin_phase_association; {thinkspace_casespace_phase: admin_phase}; end

  def read_phase_score;  {thinkspace_casespace_phase_state: read_phase_association};  end
  def admin_phase_score; {thinkspace_casespace_phase_state: admin_phase_association}; end

  def read_states;  {state: ['active']}; end
  def admin_states; {state: ['active', 'inactive', 'archived']}; end

  private

  def domain
    can [:read], Thinkspace::Casespace::PhaseTemplate
    can [:read], Thinkspace::Casespace::PhaseComponent
  end

  def assignments
    assignment = Thinkspace::Casespace::Assignment
    can [:read, :phase_states], assignment, read_assignment
    return unless admin?
    can [:read, :phase_states], assignment, admin_assignment
    can [:create], assignment
    can [:templates, :clone, :delete, :load, :update, :view, :roster, :phase_order, :phase_componentables, :activate, :inactivate], assignment, admin_assignment
    can [:gradebook, :manage_resources, :report], assignment, admin_assignment
  end

  def phases
    phase       = Thinkspace::Casespace::Phase
    phase_state = Thinkspace::Casespace::PhaseState
    phase_score = Thinkspace::Casespace::PhaseScore
    can [:read, :load, :submit], phase, read_phase
    can [:read], phase_state, read_phase_association
    can [:read], phase_score, read_phase_score
    return unless admin?
    can [:read, :load, :submit, :report], phase, admin_phase
    can [:templates, :clone, :update, :bulk_reset_date, :destroy, :componentables, :activate, :archive, :inactivate, :delete_ownerable_data], phase, admin_phase
    can [:create], [phase_state, phase_score]
    can [:update, :roster_update, :gradebook], phase_state, admin_phase_association
    can [:update, :gradebook], phase_score, admin_phase_score
  end

  # ###
  # ### Engines.
  # ###

  def artifact
    bucket = Thinkspace::Artifact::Bucket
    file   = Thinkspace::Artifact::File
    can [:read],       bucket
    can [:view_users], bucket
    can [:crud],       file
    can [:image_url, :carry_forward_image_url, :carry_forward_expert_image_url], file
    return unless admin?
    can [:update], bucket
  end

  def resource
    can [:crud], Thinkspace::Resource::File
    can [:crud], Thinkspace::Resource::Link
    can [:crud], Thinkspace::Resource::Tag
    can [:read], Thinkspace::Resource::FileTag
    can [:read], Thinkspace::Resource::LinkTag
  end

  def markup
    comment         = Thinkspace::Markup::Comment
    discussion      = Thinkspace::Markup::Discussion
    library         = Thinkspace::Markup::Library
    library_comment = Thinkspace::Markup::LibraryComment
    can [:crud, :fetch], comment
    can [:crud, :fetch], discussion
    can [:crud, :add_tag, :remove_comment_tag, :add_comment_tag, :fetch], library
    can [:crud, :select], library_comment
  end

  def html
    content = Thinkspace::Html::Content
    can [:read], content
    return unless admin?
    can [:update, :validate], content
  end

  def observation_list
    list             = Thinkspace::ObservationList::List
    observation      = Thinkspace::ObservationList::Observation
    observation_note = Thinkspace::ObservationList::ObservationNote
    group            = Thinkspace::ObservationList::Group
    can [:read, :observation_order], list
    can [:crud], observation
    can [:crud], observation_note
    return unless admin?
    can [:update, :groups, :assignable_groups, :assign_group, :unassign_group], list
    can [:read, :update, :create], group
  end

  def peer_assessment
    assessment = Thinkspace::PeerAssessment::Assessment
    review_set = Thinkspace::PeerAssessment::ReviewSet
    team_set   = Thinkspace::PeerAssessment::TeamSet
    review     = Thinkspace::PeerAssessment::Review
    overview   = Thinkspace::PeerAssessment::Overview
    can [:read], assessment
    can [:read, :submit], review_set
    can [:crud], review
    can [:read], overview
    return unless admin?
    can [:approve, :teams, :fetch, :review_sets, :team_sets, :update, :activate], assessment
    can [:approve, :unapprove], review
    can [:approve, :unapprove, :notify], review_set
    can [:approve, :unapprove, :approve_all, :unapprove_all], team_set
    can [:update], overview
  end

  def lab
    chart       = Thinkspace::Lab::Chart
    category    = Thinkspace::Lab::Category
    result      = Thinkspace::Lab::Result
    observation = Thinkspace::Lab::Observation
    can [:read], [chart, category, result, observation]
    can [:create, :update], observation
    return unless admin?
    can [:load, :category_positions], chart
    can [:crud, :result_positions], category
    can [:create, :update, :destroy], result
  end

  def input_element
    response = Thinkspace::InputElement::Response
    element  = Thinkspace::InputElement::Element
    can [:read], element
    can [:crud, :carry_forward], response
  end

  def diagnostic_path
    path      = Thinkspace::DiagnosticPath::Path
    path_item = Thinkspace::DiagnosticPath::PathItem
    can [:crud, :bulk, :bulk_destroy], path
    can [:crud], path_item
  end

  def diagnostic_path_viewer
    viewer = Thinkspace::DiagnosticPathViewer::Viewer
    can [:read], viewer
  end

  def simulation
    simulation = Thinkspace::Simulation::Simulation
    can [:read], simulation
  end

  def team
    team = get_class 'Thinkspace::Team::Team'
    return if team.blank?
    team_set      = Thinkspace::Team::TeamSet
    team_category = Thinkspace::Team::TeamCategory
    team_user     = Thinkspace::Team::TeamUser
    team_teamable = Thinkspace::Team::TeamTeamable
    team_viewer   = Thinkspace::Team::TeamViewer
    can [:read], team_category
    can [:read, :teams_view, :team_users_view, :read_commenterable], team
    return unless admin?
    can [:create, :update, :destroy, :gradebook], team
    can [:crud, :teams], team_set
    can [:read, :create, :destroy], [team_teamable, team_user, team_viewer]
  end

  def weather_forecaster
    assessment = get_class 'Thinkspace::WeatherForecaster::Assessment'
    return if assessment.blank?
    can [:read, :current_forecast], assessment
    can [:read], Thinkspace::WeatherForecaster::AssessmentItem
    can [:read], Thinkspace::WeatherForecaster::ForecastDay
    can [:read], Thinkspace::WeatherForecaster::Item
    can [:read], Thinkspace::WeatherForecaster::Station
    can [:crud], Thinkspace::WeatherForecaster::Forecast
    can [:crud], Thinkspace::WeatherForecaster::Response
    can [:read], Thinkspace::WeatherForecaster::ResponseScore
  end

  def builder
    # TODO: Authorize template once 'system and personal' scope gets added.
    template = get_class 'Thinkspace::Builder::Template'
    return if template.blank?
    can [:read], template
  end

end; end; end
