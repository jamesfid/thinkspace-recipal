module Thinkspace; module PeerAssessment; module Rows; class Phase < Base

  def assignment; @record.thinkspace_casespace_assignment; end
  def space; assignment.thinkspace_common_space; end

  def space_id; space.id; end
  def assignment_id; assignment.id; end
  
end; end; end; end
