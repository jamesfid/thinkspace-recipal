module Thinkspace::Test; module ReadinessAssurance; module All
extend ActiveSupport::Concern
included do

  include ::Thinkspace::Test::Casespace::All
  include ::Thinkspace::Test::PhaseActions::Actions
  include ::Thinkspace::Test::PhaseActions::Ownerables
  include ::Thinkspace::Test::PhaseActions::Assert
  include ::Thinkspace::Test::ReadinessAssurance::Models
  include ::Thinkspace::Test::ReadinessAssurance::Response
  include ::Thinkspace::Test::ReadinessAssurance::Answers
  include ::Thinkspace::Test::ReadinessAssurance::Ownerables
  include ::Thinkspace::Test::ReadinessAssurance::Params
  include ::Thinkspace::Test::ReadinessAssurance::Assert

  include ::Thinkspace::Test::ReadinessAssurance::Route::Irats
  include ::Thinkspace::Test::ReadinessAssurance::Route::SubmitIrat

end; end; end; end
