module Thinkspace; module PeerAssessment; module Sheets; class Categories < Base
  attr_reader :reviews
  
  def type; 'categories'; end

  def headers
    headers = [
     'id', 'space_title', 'space_id',
     'assignment_title', 'assignment_id',
     'phase_title', 'phase_id', 'team_title',
     'team_id', 'reviewer_id', 'reviewee_id',
     'state', 'type'
    ]
    (1..15).each do |i|
      headers.push("quant_#{i}_label")
      headers.push("quant_#{i}_value")
      headers.push("quant_#{i}_comment")
    end
    (1..10).each do |i|
      headers.push("qual_#{i}_label")
      headers.push("qual_#{i}_type")
      headers.push("qual_#{i}_value")
    end
    headers
  end

  def process
    set_reviews
    set_rows
  end

  def set_reviews
    assessments_sheet = @caller.sheet_by_name('Assessments')
    @all_assessments  = assessments_sheet.assessments
    assessment_ids    = @all_assessments.pluck(:id) # Reset the scope.
    @assessments      = assessment_class.where(id: assessment_ids).where("thinkspace_peer_assessment_assessments.value #>> '{options, type}' = '#{type}'")
    review_ids        = @assessments.joins(thinkspace_peer_assessment_team_sets: {thinkspace_peer_assessment_review_sets: :thinkspace_peer_assessment_reviews}).distinct.pluck('thinkspace_peer_assessment_reviews.id')
    @reviews          = review_class.where(id: review_ids)
  end

  def set_rows
    @rows[:reviews] = @reviews.map { |r| row_for_record(self, r) }
  end

  # # Worksheet
  def add_worksheet_rows
    @rows[:reviews].each_with_index do |s, i|
      @worksheet.update_row (i + 1), *s.serialize_to_array
    end
  end

end; end; end; end
