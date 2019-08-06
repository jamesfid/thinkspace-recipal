module Thinkspace; module PeerAssessment; module Rows; class ReviewSet < Base

  def initialize(sheet, model)
    @rows              = {}
    @record            = model
    @sheet             = sheet
    @team_set          = @record.thinkspace_peer_assessment_team_set
    @team              = @team_set.thinkspace_team_team
    @assessment        = @team_set.thinkspace_peer_assessment_assessment
    @rows[:assessment] = row_for_record(self, @assessment)
    @phase             = @rows[:assessment].phase
    @assignment        = @rows[:assessment].assignment
    @space             = @rows[:assessment].space
    @reviewer          = @record.ownerable
    @anonymous_json    = anonymous_json_for_review_set
  end

  def method_missing(m, *args)
    parts = m.to_s.split('_')
    if /quant/ =~ m
      quant_value(parts[1], parts[2])
    end
  end

  def quant_value(id, prop)
    case prop
    when 'label'
      items = assessment_value.dig(:quantitative)
      return nil unless items
      obj = items.find { |q| q['id'].to_s == id.to_s }
      return nil unless obj
      obj.with_indifferent_access[prop]
    when 'value'
      @anonymous_json.with_indifferent_access.dig(:quantitative, id)
    else
      puts "Could not find a method for quant prop [#{prop}] for a ::Rows::Review."
    end
  end

  def anonymous_json_for_review_set
    reviews = @record.thinkspace_peer_assessment_reviews
    review_class.generate_anonymized_review_json(@assessment, reviews)
  end

  #def value; @record.value.present? ? @record.value.with_indifferent_access : {}; end
  def assessment_value; @assessment.value.present? ? @assessment.value.with_indifferent_access : {}; end

  def space_title; @space.title; end
  def space_id; @space.id; end
  def assignment_title; @assignment.title; end
  def assignment_id; @assignment.id; end
  def phase_title; @phase.title; end
  def phase_id; @phase.id; end
  def team_title; @team.present? ? @team.title : nil; end
  def team_id; @team.present? ? @team.id : nil; end
  def reviewer_id; @reviewer.id; end
  def reviewee_id; @reviewee.id; end
  def state; @record.state; end
  def type; @assessment.assessment_type; end

end; end; end; end
