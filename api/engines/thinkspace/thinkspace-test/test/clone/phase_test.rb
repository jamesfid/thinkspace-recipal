require 'clone/test_helper'

module Test; module Clone; class Phase < ActiveSupport::TestCase
  include ::Thinkspace::Test::Clone::All

  describe 'clone phases'  do
    let (:ownerable)       {get_user(:update_1)}
    let (:user)            {get_user(:read_1)}
    let (:assignment)      {get_assignment(:clone_assignment)}
    let (:record)          {get_phase(:clone_phase, assignment_id: assignment.id)}
    let (:into_space)      {create_into_clone_space}
    let (:into_assignment) {create_into_clone_assignment(into_space)}

    describe 'single phase' do
      # let (:print_ids) {true}
      it "clone phase" do
        cloned_phase, options = clone_record
        assert_phase_clone record, cloned_phase, options
      end
    end

    describe 'phase title override' do
      # let (:print_ids) {true}
      it "clone phase" do
        cloned_phase, options = clone_record title: :test_title
        assert_phase_clone record, cloned_phase, options
      end
    end

    describe 'single phase into another assignment' do
      # let (:print_ids)       {true}
      # let (:clone_dictionary_header) {"From assignment #{assignment.title.inspect} [id: #{assignment.id}] into #{into_assignment.title.inspect} [id: #{into_assignment.id}]"}
      it 'clone phase into assignment' do
        cloned_phase, options = clone_record assignment: into_assignment, keep_title: true
        assert_phase_clone record, cloned_phase, options.merge(except_attributes: :assignment_id)
        assert_equal into_assignment.id, cloned_phase.assignment_id, "cloned phase in the correct assignment [id: #{into_assignment.id}]"
      end
    end

  end

end; end; end
