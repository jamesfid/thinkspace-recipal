module Thinkspace; module PeerAssessment; module Sheets; class Assignments < Base
  attr_reader :assignments
  
  def headers; ['id', 'space_id', 'title', 'bundle_type', 'instructions', 'created_at', 'updated_at', 'state', 'release_at', 'due_at']; end

  # # Processing
  def process
    set_assignments
    set_rows
  end

  def set_assignments
    phases_sheet   = @caller.sheet_by_name('Phases')
    @phases        = phases_sheet.phases
    assignment_ids = @phases.pluck(:assignment_id)
    @assignments   = assignment_class.where(id: assignment_ids)
  end

  def set_rows
    @rows[:assignments] = @assignments.map { |a| row_for_record(self, a) }
  end

  # # Worksheet
  def add_worksheet_rows
    @rows[:assignments].each_with_index do |s, i|
      @worksheet.update_row (i + 1), *s.serialize_to_array
    end
  end

end; end; end; end
