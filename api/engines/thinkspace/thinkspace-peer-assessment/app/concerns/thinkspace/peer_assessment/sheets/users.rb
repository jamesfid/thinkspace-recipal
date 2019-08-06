module Thinkspace; module PeerAssessment; module Sheets; class Users < Base
  
  def headers
    if @caller.is_master?
      headers = [
        'id', 'last_name', 'first_name', 'email', 
        'created_at', 'updated_at', 'activated_at',
        'last_sign_in_at'
      ]
    else
      headers = [
        'id', 'created_at', 'updated_at',
        'activated_at', 'last_sign_in_at'
      ]
    end
  end

  # # Processing
  def process
    set_users
    set_rows
  end

  def set_users
    space_users_sheet = @caller.sheet_by_name('SpaceUsers')
    @space_users      = space_users_sheet.space_users
    user_ids          = @space_users.distinct.pluck(:user_id)
    @users            = user_class.where(id: user_ids)
  end

  def set_rows
    @rows[:users] = @users.map { |u| row_for_record(self, u) }
  end

  # # Worksheet
  def add_worksheet_rows
    @rows[:users].each_with_index do |s, i|
      @worksheet.update_row (i + 1), *s.serialize_to_array
    end
  end


end; end; end; end
