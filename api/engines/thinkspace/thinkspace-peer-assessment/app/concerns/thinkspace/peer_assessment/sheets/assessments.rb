module Thinkspace; module PeerAssessment; module Sheets; class Assessments < Base
  attr_reader :assessments

  def headers; ['id', 'space_id', 'assignment_id', 'phase_id', 'state', 'type', 'descriptive', 'descriptive_min', 'descriptive_max', 'points_per_member', 'created_at', 'updated_at']; end

  # # Processing
  def process
    set_assessments
    set_rows
  end

  def set_assessments
    spaces_sheet   = @caller.sheet_by_name('Spaces')
    @spaces        = spaces_sheet.spaces
    assessment_ids = @spaces.joins(thinkspace_casespace_assignments: {thinkspace_casespace_phases: :thinkspace_casespace_phase_components}).where('thinkspace_casespace_phase_components.componentable_type = ?', assessment_class.name).pluck('thinkspace_casespace_phase_components.componentable_id')
    @assessments   = assessment_class.where(id: assessment_ids).where("value #>> '{options, type}' = 'balance' OR value #>> '{options, type}' = 'categories'")
  end

  def set_rows
    @rows[:assessments] = @assessments.map { |a| row_for_record(self, a) }
  end

  # # Worksheet
  def add_worksheet_rows
    @rows[:assessments].each_with_index do |s, i|
      @worksheet.update_row (i + 1), *s.serialize_to_array
    end
  end


end; end; end; end
