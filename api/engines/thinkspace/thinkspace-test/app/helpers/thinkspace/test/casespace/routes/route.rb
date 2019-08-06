module Cnc::Test; module Casespace; module Routes; class Route < ::Totem::Test::Routes::Route

  include ::Thinkspace::Test::Common::Models

  def dictionary_user;        dictionary_model(user_class); end
  def dictionary_space;       dictionary_model(space_class); end
  def dictionary_assignment;  dictionary_model(assignment_class); end
  def dictionary_phase;       dictionary_model(phase_class); end
  def dictionary_phase_state; dictionary_model(phase_state_class); end

end; end; end; end
