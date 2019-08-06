module Thinkspace; module PeerAssessment; module Sheets; class TeamUsers < Base
  attr_reader :team_users

  def headers; ['id', 'user_id', 'team_id', 'created_at', 'updated_at']; end

  # # Processing
  def process
    set_team_users
    set_rows
  end

  def set_team_users
    teams_sheet = @caller.sheet_by_name('Teams')
    @teams      = teams_sheet.teams
    team_ids    = @teams.pluck(:id)
    @team_users = team_user_class.where(team_id: team_ids)
  end

  def set_rows
    @rows[:team_users] = @team_users.map { |tu| row_for_record(self, tu) }
  end

  # # Worksheet
  def add_worksheet_rows
    @rows[:team_users].each_with_index do |s, i|
      @worksheet.update_row (i + 1), *s.serialize_to_array
    end
  end

end; end; end; end
