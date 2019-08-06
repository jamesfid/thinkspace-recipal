module Thinkspace; module PeerAssessment; module Rows; class Assessment < Base


  def descriptive; options.dig(:points, :descriptive, :enabled); end
  def descriptive_min
    values = options.dig(:points, :descriptive, :values)
    return nil unless values
    values.first
  end
  def descriptive_max
    values = options.dig(:points, :descriptive, :values)
    return nil unless values
    values.last
  end
  def points_per_member; options.dig(:points, :per_member).to_f || nil; end;


  def phase; @record.authable; end;
  def assignment; phase.thinkspace_casespace_assignment; end;
  def space; assignment.thinkspace_common_space; end;
  def teams; team_class.scope_by_teamables(phase); end

  def space_id; space.id; end
  def assignment_id; assignment.id; end
  def phase_id; phase.id; end
  def type; @record.assessment_type; end

  def options; @record.options.with_indifferent_access; end

  def is_categories?
    return false unless @record && @record.assessment_type
    @record.assessment_type == 'categories'
  end

  def is_balance?
    return false unless @record && @record.assessment_type
    @record.assessment_type == 'balance'
  end

  def is_valid_type?
    (is_categories? || is_balance?) ? true : false
  end

end; end; end; end
