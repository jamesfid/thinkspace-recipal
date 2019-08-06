module Thinkspace; module PeerAssessment; module Rows; class Team < Base

  def space_id
    authable = @record.authable
    case 
    when authable.class == space_class
      authable.id
    when authable.class == phase_class
      assignment = authable.thinkspace_casespace_assignment
      return 'N/A' unless assignment
      assignment.thinkspace_common_space.id
    else
      "INVALID CLASS"
    end
  end

end; end; end; end
