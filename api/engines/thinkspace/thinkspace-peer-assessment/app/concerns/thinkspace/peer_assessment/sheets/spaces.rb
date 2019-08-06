module Thinkspace; module PeerAssessment; module Sheets; class Spaces < Base
  attr_reader :spaces

  def ilike_email; '%iastate%'; end

  def headers; ['id', 'title', 'created_at', 'updated_at']; end

  # # Processing
  def process
    set_spaces
    set_rows
  end

  # # Setters
  def set_spaces
    space_ids  = phase_component_class.where(componentable_type: assessment_class.name).joins(thinkspace_casespace_phase: {thinkspace_casespace_assignment: :thinkspace_common_space}).pluck('thinkspace_common_spaces.id').uniq
    scoped_ids = space_class.where(id: space_ids).joins(thinkspace_common_space_users: :thinkspace_common_user).where('thinkspace_common_users.email ILIKE ?', ilike_email).pluck('thinkspace_common_spaces.id').uniq
    @spaces    = space_class.where(id: scoped_ids)
  end

  def set_assessments
    ids = @record.thinkspace_casespace_assignments.joins(thinkspace_casespace_phases: :thinkspace_casespace_phase_components).where('thinkspace_casespace_phase_components.componentable_type = ?', assessment_class.name).pluck('thinkspace_casespace_phase_components.componentable_id')
    @assessments = assessment_class.where(id: ids)
  end

  def set_rows
    @rows[:spaces] = @spaces.map { |s| row_for_record(self, s) }
  end

  # # Worksheet
  def add_worksheet_rows
    @rows[:spaces].each_with_index do |s, i|
      @worksheet.update_row (i + 1), *s.serialize_to_array
    end
  end

  
end; end; end; end
