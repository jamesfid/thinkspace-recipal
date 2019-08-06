module Thinkspace; module Authorization
class ThinkspaceReporter < ::Totem::Settings.authorization.platforms.thinkspace.cancan.classes.ability_engine

  def process; call_private_methods; end

  private

  def reports
    r = get_class 'Thinkspace::Reporter::Report'
    return if r.blank?
    report = Thinkspace::Reporter::Report
    file   = Thinkspace::Reporter::File
    can [:read, :destroy], report, thinkspace_common_user: current_user
    can [:generate, :access], report
    can [:read], file, thinkspace_reporter_report: {user_id: current_user.id}
  end

end; end; end
