module Thinkspace; module Migrate; module ToComponents; module Inspect
  class PhaseScores < Totem::DbMigrate::BaseHelper
    require 'pp'

    def process
      phase_states = old_phase_state_class.all
      phase_scores = old_phase_score_class.all
      puts "Phase state count: #{phase_states.count}"
      puts "Phase score count: #{phase_scores.count}"
      orphan_phase_scores
    end

    def orphan_phase_scores
      orphans = Array.new
      old_phase_score_class.all.each do |score|
        phase_state = old_phase_state_class.find_by(
          ownerable_type: score.ownerable_type,
          ownerable_id:   score.ownerable_id,
          phase_id:       score.phase_id,
        )
        orphans.push(score)  if phase_state.blank?
      end
      puts "Phase scores without a phase state count: #{orphans.length}"
      pp orphans
    end

    def old_phase_state_class; get_old_model_class('thinkspace/wips/casespace/phase_state'); end
    def old_phase_score_class; get_old_model_class('thinkspace/wips/casespace/phase_score'); end

  end
  
end; end; end; end

# Result on 07/09/2015:
# Phase state count: 23502
# Phase score count: 12839
# Phase scores without a phase state count: 3
# [#<Totem::DbMigrate::OldModel::Thinkspace::Wips::Casespace::PhaseScore:0xbdd43b0
#   id: 10375,
#   user_id: nil,
#   phase_id: 832,
#   score: #<BigDecimal:f95f2f4,'0.1E1',9(18)>,
#   created_at: Fri, 08 May 2015 13:55:57 UTC +00:00,
#   updated_at: Fri, 08 May 2015 13:55:58 UTC +00:00,
#   ownerable_id: 106,
#   ownerable_type: "Thinkspace::Common::User">,
#  #<Totem::DbMigrate::OldModel::Thinkspace::Wips::Casespace::PhaseScore:0xcc32f24
#   id: 5997,
#   user_id: nil,
#   phase_id: 649,
#   score: #<BigDecimal:f95d468,'0.5E1',9(18)>,
#   created_at: Fri, 13 Feb 2015 17:18:26 UTC +00:00,
#   updated_at: Fri, 13 Feb 2015 17:18:27 UTC +00:00,
#   ownerable_id: 2,
#   ownerable_type: "Thinkspace::Common::User">,
#  #<Totem::DbMigrate::OldModel::Thinkspace::Wips::Casespace::PhaseScore:0xcfb7910
#   id: 10195,
#   user_id: nil,
#   phase_id: 741,
#   score: #<BigDecimal:f9535f8,'0.1E1',9(18)>,
#   created_at: Fri, 01 May 2015 19:23:55 UTC +00:00,
#   updated_at: Fri, 01 May 2015 19:23:55 UTC +00:00,
#   ownerable_id: 103,
#   ownerable_type: "Thinkspace::Common::User">]
