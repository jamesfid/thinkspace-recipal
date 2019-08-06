module Thinkspace; module Authorization
class ThinkspaceIndentedList < ::Totem::Settings.authorization.platforms.thinkspace.cancan.classes.ability_engine

  def process; call_private_methods; end

  private

  def indented_list
    list     = Thinkspace::IndentedList::List
    response = Thinkspace::IndentedList::Response
    expert   = Thinkspace::IndentedList::ExpertResponse
    can [:read], list
    can [:crud], response
    can [:crud], expert
    return unless admin?
    can [:update, :set_expert_response], list
  end

end; end; end
