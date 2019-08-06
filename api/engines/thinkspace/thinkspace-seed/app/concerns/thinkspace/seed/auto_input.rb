module Thinkspace::Seed::AutoInput

  def set_options(options)
    @indent         = options[:indent]                || 0  # add an indent level to text e.g. 1.1, 1.11, etc. (should match indented list indent)
    @user_column    = options[:user_column]           || :first_name
    @include_spaces = [options[:spaces]].flatten.compact
    @include_phases = [options[:phases]].flatten.compact
    @include_users  = [options[:users]].flatten.compact
    @include_teams  = [options[:teams]].flatten.compact
    @current_indent = nil
  end

  def skip_ownerable?(ownerable); user?(ownerable) ? skip_user?(ownerable) : skip_team?(ownerable); end

  def skip_spacee?(space); @include_spaces.present? && !@include_spaces.include?(space.title); end
  def skip_phase?(phase);  @include_phases.present? && !@include_phases.include?(phase.title); end
  def skip_user?(user);    @include_users.present?  && !@include_users.include?(user.first_name); end
  def skip_team?(team);    @include_teams.present?  && !@include_teams.include?(team.title); end

  def ownerable_text(ownerable); team?(ownerable) ? ownerable.title : ownerable.send(@user_column); end

  def indent_text
    return '' if @indent == 0
    case
    when @current_indent.blank?             then @current_indent = [1]
    when @current_indent.length >= @indent  then @current_indent = [@current_indent.first + 1]
    else                                         @current_indent.push(1)
    end
    @current_indent.join('.') + '. '
  end

  def clear_current_indent; @current_indent = nil; end

end
