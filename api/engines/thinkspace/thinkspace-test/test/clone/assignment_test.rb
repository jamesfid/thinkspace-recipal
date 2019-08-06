require 'clone/test_helper'

module Test; module Clone; class Assignment < ActiveSupport::TestCase
  include ::Thinkspace::Test::Clone::All

  describe 'clone assignments'  do
    let (:ownerable)  {get_user(:update_1)}
    let (:user)       {get_user(:read_1)}
    let (:record)     {get_assignment(:clone_assignment)}

    describe 'single assignment' do
      let (:into_space) {create_into_clone_space}
      # let (:print_ids) {true}
      it "clone" do
        cloned_assignment, options = clone_record
        assert_assignment_clone record, cloned_assignment, options.merge(keep_title: false)
      end
    end

    describe 'assignment title override' do
      let (:into_space) {create_into_clone_space}
      # let (:print_ids) {true}
      it "clone" do
        cloned_assignment, options = clone_record title: :test_title
        assert_assignment_clone record, cloned_assignment, options.merge(keep_title: false)
      end
    end

    describe 'single assignment into another space' do
      let (:into_space) {create_into_clone_space}
      # let (:print_ids)  {true}
      it 'clone into space' do
        cloned_assignment, options = clone_record space: into_space, keep_title: true
        assert_assignment_clone record, cloned_assignment, options.merge(except_attributes: :space_id)
        assert_equal into_space.id, cloned_assignment.space_id, "cloned assignment in the correct space [id: #{into_space.id}]"
      end
    end

    describe 'same assignment cloned twice into another space' do
      # let (:print_ids)  {true}
      it 'clone twice into space' do
        into_space1 = create_into_clone_space
        into_space2 = create_into_clone_space
        cloned_assignment1, options1 = clone_record space: into_space1, keep_title: true
        assert_assignment_clone record, cloned_assignment1, options1.merge(except_attributes: :space_id)
        assert_equal into_space1.id, cloned_assignment1.space_id, "cloned assignment in the correct space [id: #{into_space1.id}]"
        cloned_assignment2, options2 = clone_record space: into_space2, keep_title: true
        assert_assignment_clone record, cloned_assignment2, options2.merge(except_attributes: :space_id)
        assert_equal into_space2.id, cloned_assignment2.space_id, "cloned assignment in the correct space [id: #{into_space2.id}]"
        assert_equal cloned_assignment1.title, cloned_assignment2.title, "both cloned assignments have same title"
      end
    end

  end

end; end; end
