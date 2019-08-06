module Thinkspace; module PeerAssessment; module Sheets; class Both < Categories
  attr_reader :reviews
  
  def process
    set_rows
  end

  def set_rows
    categories_sheet = @caller.sheet_by_name('Categories')
    balance_sheet    = @caller.sheet_by_name('Balance')
    @rows[:reviews]  = categories_sheet.rows[:reviews] + balance_sheet.rows[:reviews]
  end

end; end; end; end
