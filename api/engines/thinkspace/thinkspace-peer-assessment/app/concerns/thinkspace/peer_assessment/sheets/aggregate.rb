module Thinkspace; module PeerAssessment; module Sheets; class Aggregate < Base

  def type; 'categories'; end

  def headers
    headers = [
     'space_title', 'space_id',
     'assignment_title', 'assignment_id',
     'phase_title', 'phase_id', 'team_title',
     'team_id', 'reviewer_id',
     'state', 'type'
    ]
    (1..15).each do |i|
      headers.push("quant_#{i}_label")
      headers.push("quant_#{i}_value")
    end
    headers
  end

  def process
    set_review_sets
    set_rows
  end

  def set_review_sets
    categories_sheet = @caller.sheet_by_name('Categories')
    balance_sheet    = @caller.sheet_by_name('Balance')
    review_ids       = categories_sheet.reviews.pluck(:id) + balance_sheet.reviews.pluck(:id)
    @reviews         = review_class.where(id: review_ids)
    review_set_ids   = @reviews.joins(:thinkspace_peer_assessment_review_set).distinct.pluck('thinkspace_peer_assessment_review_sets.id')
    @review_sets     = review_set_class.where(id: review_set_ids)
  end

  def set_rows
    @rows[:review_sets] = @review_sets.map { |r| row_for_record(self, r) }
  end

  # # Worksheet
  def add_worksheet_rows
    @rows[:review_sets].each_with_index do |s, i|
      @worksheet.update_row (i + 1), *s.serialize_to_array
    end
  end

end; end; end; end
