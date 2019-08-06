module Thinkspace; module PeerAssessment; module Sheets; class SpaceUsers < Base
  attr_reader :space_users

  def headers; ['id', 'space_id', 'user_id', 'role', 'created_at', 'updated_at']; end

  def process
    spaces_sheet = @caller.sheet_by_name('Spaces')
    @spaces      = spaces_sheet.spaces
    set_space_users
    set_rows
  end

  def set_space_users
    space_ids    = @spaces.pluck(:id)
    @space_users = space_user_class.where(space_id: space_ids)
  end

  def set_rows
    @rows[:space_users] = @space_users.map { |su| row_for_record(self, su) }
  end

  # # Worksheet
  def add_worksheet_rows
    @rows[:space_users].each_with_index do |s, i|
      @worksheet.update_row (i + 1), *s.serialize_to_array
    end
  end

end; end; end; end
