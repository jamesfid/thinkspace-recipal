module Thinkspace::Seed::Classes

  def user_class;             @user_class             ||= @seed.model_class(:common, :user); end
  def common_component_class; @common_component_class ||= @seed.model_class(:common, :component); end
  def space_class;            @space_class            ||= @seed.model_class(:common, :space); end
  def assignment_class;       @assignment_class       ||= @seed.model_class(:casespace, :assignment); end
  def phase_class;            @phase_class            ||= @seed.model_class(:casespace, :phase); end
  def phase_component_class;  @phase_component_class  ||= @seed.model_class(:casespace, :phase_component); end
  def team_class;             @team_class             ||= @seed.model_class(:team, :team); end

  def user?(model); model.is_a?(user_class); end
  def team?(model); model.is_a?(team_class); end

end
