namespace :thinkspace do
  namespace :peer_assessment do

    task :mg_dump, [] => [:environment] do |t, args|
      Thinkspace::PeerAssessment::MillerGrant.new().process
    end


    # def init_mg_dump
    #   @rows = {spaces: [], space_users: [], users: [], teams: [], team_users: [], assignments: [], phases: [], assessments: [], categories: [], balance: [], aggregate: []}
    #   set_assessment_spaces
    # end

    # def process
    #   # Set all @rows keys.
    #   @spaces.each do |space|
    #     add_row(:spaces, space)
    #     process_space(space)
    #   end
    # end

    # def process_space(space) 

    # end

    # def add_row(key, record)
    #   return unless key && record
    #   type = record.class.name.split('::').pop.downcase
    #   fn   = "row_for_#{type}"
    #   row  = self.send(fn, record)
    #   @rows[key].push(row)
    # end

    # def row_for_space(s, options={})
    #   {id: s.id, title: s.title, created_at: s.created_at, updated_at: s.updated_at}
    # end

    # def row_for_assessment(a, options={})
    #   phase      = a.authable
    #   assignment = phase.thinkspace_casespace_assignment
    #   space      = assignment.thinkspace_common_space
    #   # Needs descriptive: true|false, descriptive_min, descriptive_max
    #   {
    #     id: a.id,                     space_id: space.id, 
    #     assignment_id: assignment.id, state: a.state,
    #     type: a.assessment_type,      points_per_member: points_per_member(a),
    #     created_at: a.created_at,     updated_at: a.updated_at
    #   }
    # end

    # def is_categories?(a)
    #   return false unless a && a.assessment_type
    #   a.assessment_type == 'categories'
    # end

    # def is_balance?(a)
    #   return false unless a && a.assessment_type
    #   a.assessment_type == 'balance'
    # end

    # def is_descriptive?(a)

    # end

    # def points_per_member(a)
    #   a.value.with_indifferent_access.dig(:options, :points, :per_member).to_f || nil
    # end

    # def assessment_class; Thinkspace::PeerAssessment::Assessment; end

  end
end
