module Thinkspace; module PeerAssessment; module Sheets; class Phases < Base
  attr_reader :phases
  
  def headers; ['id', 'space_id', 'assignment_id', 'title', 'description', 'position', 'created_at', 'updated_at']; end

  # # Processing
  def process
    set_phases
    set_rows
  end

  def set_phases
    assessments_sheet = @caller.sheet_by_name('Assessments')
    @assessments      = assessments_sheet.assessments
    phase_ids         = @assessments.pluck(:authable_id)
    @phases           = phase_class.where(id: phase_ids)
  end

  def set_rows
    @rows[:phases] = @phases.map { |p| row_for_record(self, p) }
  end

  # # Worksheet
  def add_worksheet_rows
    @rows[:phases].each_with_index do |s, i|
      @worksheet.update_row (i + 1), *s.serialize_to_array
    end
  end

end; end; end; end
