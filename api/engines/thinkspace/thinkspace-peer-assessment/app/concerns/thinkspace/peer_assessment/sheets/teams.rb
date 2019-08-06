module Thinkspace; module PeerAssessment; module Sheets; class Teams < Base
  attr_reader :teams

  def headers; ['id', 'title', 'color', 'space_id', 'created_at', 'updated_at']; end

  # # Processing
  def process
    set_teams
    set_rows
  end

  def set_teams
    assessments_sheet = @caller.sheet_by_name('Assessments')
    @assessments      = assessments_sheet.assessments
    team_ids          = @assessments.joins(:thinkspace_peer_assessment_team_sets).distinct.pluck(:team_id)
    @teams            = team_class.where(id: team_ids)
  end

  def set_rows
    @rows[:teams] = @teams.map { |t| row_for_record(self, t) }
  end

  # # Worksheet
  def add_worksheet_rows
    @rows[:teams].each_with_index do |s, i|
      @worksheet.update_row (i + 1), *s.serialize_to_array
    end
  end
end; end; end; end
