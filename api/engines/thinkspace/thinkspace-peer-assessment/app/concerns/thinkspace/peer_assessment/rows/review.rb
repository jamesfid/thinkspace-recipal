module Thinkspace; module PeerAssessment; module Rows; class Review < Base

  def initialize(sheet, model)
    @rows              = {}
    @record            = model
    @sheet             = sheet
    @review_set        = model.thinkspace_peer_assessment_review_set
    @team_set          = @review_set.thinkspace_peer_assessment_team_set
    @team              = @team_set.thinkspace_team_team
    @assessment        = @team_set.thinkspace_peer_assessment_assessment
    @rows[:assessment] = row_for_record(self, @assessment)
    @phase             = @rows[:assessment].phase
    @assignment        = @rows[:assessment].assignment
    @space             = @rows[:assessment].space
    @reviewer          = @review_set.ownerable
    @reviewee          = model.reviewable
  end

  def method_missing(m, *args)
    parts = m.to_s.split('_')
    if /quant/ =~ m
      quant_value(parts[1], parts[2])
    elsif /qual/ =~ m
      qual_value(parts[1], parts[2])
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
      value.dig(:quantitative, id, prop)
    when 'comment'
      value.dig(:quantitative, id, 'comment', 'value')
    else
      puts "Could not find a method for quant prop [#{prop}] for a ::Rows::Review."
    end
  end

  def qual_value(id, prop)
    case prop
    when 'label'
      items = assessment_value.dig(:qualitative)
      return nil unless items
      obj = items.find { |q| q['id'].to_s == id.to_s }
      return nil unless obj
      obj.with_indifferent_access[prop]
    when 'type'
      value.dig(:qualitative, id, 'feedback_type')
    when 'value'
      value.dig(:qualitative, id, 'value')
    else
      puts "Could not find a method for qual prop [#{prop}] for a ::Rows::Review."
    end
  end

  def value; @record.value.present? ? @record.value.with_indifferent_access : {}; end
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
