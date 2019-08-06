require 'serializer_asm10/test_helper'

module Test; module SerializerAsm10; class AbilityAddToModelTest < ActionController::TestCase
  include ::Thinkspace::Test::SerializerAsm10::All

  add_test(Proc.new do |route|
    describe 'read_1 assignment show' do
      let(:user)      {read_1}
      let(:record)    {serializer_assignment}
      let(:abilities) {get_test_abilities}
      before do; @route = route; end
      it 'has model attributes' do
        serializer_options.include_ability(abilities.merge(add_to_model: true))
        json = send_route_request
        assert_model_abilities(json)
        assert_included_ability(json)
      end
      it 'has does not have model attributes' do
        serializer_options.include_ability(abilities)
        json = send_route_request
        refute_model_abilities(json)
        assert_included_ability(json)
      end
    end
  end) # proc

  co = new_route_config_options(tests: get_tests, test_action: :show)
  co.only :casespace, :assignments, :show
  run_tests_serializer(co)

end; end; end
