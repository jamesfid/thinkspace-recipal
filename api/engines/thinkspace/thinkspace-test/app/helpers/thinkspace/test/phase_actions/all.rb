module Thinkspace::Test; module PhaseActions; module All
extend ActiveSupport::Concern
included do

  include ::Thinkspace::Test::Casespace::All
  include ::Thinkspace::Test::PhaseActions::Actions
  include ::Thinkspace::Test::PhaseActions::Assert
  include ::Thinkspace::Test::PhaseActions::Ownerables
  include ::Thinkspace::Test::PhaseActions::Submit

end; end; end; end
