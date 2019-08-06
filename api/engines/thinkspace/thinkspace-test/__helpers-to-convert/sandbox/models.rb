module Thinkspace::Test; module Sandbox; module Models
extend ActiveSupport::Concern
included do

  def user_cases
    cases = [sandbox_assignment]
    cases.push get_assignment('Read 1 Sandbox Case (NOT Master)') if user.first_name == 'read_1'
    cases
  end

  def not_sandbox_space_title;      'NOT Sandbox Space'; end
  def not_sandbox_assignment_title; 'NOT Sandbox Case'; end

  def not_sandbox_space; get_space(not_sandbox_space_title); end
  def sandbox_space;     get_space('Sandbox Space (Master)'); end

  def read_1_space; @_read_1_space ||= get_space('Read 1 Sandbox Space'); end
  def read_2_space; @_read_2_space ||= get_space('Read 2 Sandbox Space'); end
  def read_3_space; @_read_3_space ||= get_space('Read 3 Sandbox Space'); end

  def not_sandbox_assignment; get_assignment(not_sandbox_assignment_title); end
  def sandbox_assignment;     get_assignment('Sandbox Case (Master)'); end

  def read_1_sandbox_phase; @_read_1_sandbox_phase ||= sandbox_assignment.thinkspace_casespace_phases.first; end

  def get_next_not_record_count; @_not_record_count = (@_not_record_count || 0) + 1; end

  def create_not_sandbox_space
    space = space_class.create(title: not_sandbox_space_title + get_next_not_record_count.to_s, state: :active)
    save_model(space) # ensure no validation errors
    space_user = space_user_class.create(user_id: user.id, space_id: space.id, role: :read, state: :active)
    save_model(space_user) # ensure no validation errors
    space
  end

  def create_not_sandbox_assignment(space)
    assignment = assignment_class.create(title: not_sandbox_assignment_title + get_next_not_record_count.to_s, space_id: space.id, state: :active)
    save_model(assignment) # ensure no validation errors
    assignment.get_or_set_timetable_for_self(due_at: Time.now + 7.days, release_at: Time.now - 7.days)
    assignment
  end

end; end; end; end
