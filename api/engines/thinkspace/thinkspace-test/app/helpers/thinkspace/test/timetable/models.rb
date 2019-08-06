module Thinkspace::Test; module Timetable; module Models
extend ActiveSupport::Concern
included do

  def timetable_class;       ::Thinkspace::Common::Timetable; end
  def timetable_scope_class; ::Thinkspace::Common::Timetable::Scope; end

  def time_now; @time_now ||= Time.now; end

  # Using this method since the assignments model's 'scope_open' originally did not
  # include a 'due_at' check.  Added 'due_at' to the assgignment's scope, but if remove
  # it will need change this to factor in the due_at.
   def ownerable_open_assignments
    assignments.scope_open(ownerable).order(:id).to_ary
  end

  # Using this method since the phase model's 'scope_open' originally did not
  # include a 'due_at' check.  Added 'due_at' to the phase's scope, but if remove
  # it will need change this to factor in the due_at.
   def ownerable_open_phases
    phases.scope_open(ownerable).order(:id).to_ary
  end

  def create_ownerable_timetable(options={})
    ra, da        = get_release_at_and_due_at(options)
    tt_timeable   = options[:timeable] || timeable
    tt            = timetable_class.find_by(timeable: tt_timeable, ownerable: ownerable) || timetable_class.new
    tt.timeable   = tt_timeable
    tt.ownerable  = ownerable
    tt.release_at = ra
    tt.due_at     = da
    save_model(tt)
    tt
  end

  def create_timetable(options={})
    ra, da        = get_release_at_and_due_at(options)
    tt_timeable   = options[:timeable] || timeable
    tt            = timetable_class.find_by(timeable: tt_timeable, ownerable: nil) || timetable_class.new
    tt.timeable   = tt_timeable
    tt.release_at = ra
    tt.due_at     = da
    save_model(tt)
    tt
  end

  def get_release_at_and_due_at(options={})
    case options[:when]
    when :past     then release_at = time_now - 2.days; due_at = time_now - 1.days
    when :future   then release_at = time_now + 1.days; due_at = time_now + 2.day
    else
      release_at = options[:release_at] || time_now - 1.days
      due_at     = options[:due_at]     || time_now + 1.days
    end
    [release_at, due_at]
  end

  def print_phase_timetables(ownerable=nil)
    phases.each do |phase|
      pp ownerable.blank? ? phase.thinkspace_common_timetables : phase.thinkspace_common_timetables.where(ownerable:ownerable)
    end
  end

end; end; end; end
