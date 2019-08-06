require 'serializer_asm10/test_helper'

module Test; module SerializerAsm10; class CacheIncludeAbilityTest < ActionController::TestCase
  include ::Thinkspace::Test::SerializerAsm10::All

  add_test(Proc.new do |route|
    describe 'read_1 assignment show include ability' do
      let(:user)      {read_1}
      let(:record)    {serializer_assignment}
      let(:abilities) {get_test_abilities}
      before do; @route = route; end
      it 'in cache key' do
        setup_cache_serializer_options
        serializer_options.cache(ownerable: user)
        serializer_options.include_ability(abilities)
        json = send_route_request
        key  = cache_key(ownerable: user)
        assert_included_ability_in_cache_key(json, key)
      end
      it 'not in cache key' do
        setup_cache_serializer_options
        serializer_options.cache(ownerable: user, include_ability: false)
        serializer_options.include_ability(abilities)
        json = send_route_request
        key  = cache_key(ownerable: user)
        refute_included_ability_in_cache_key(json, key)
      end
    end
  end) # proc

  co = new_route_config_options(tests: get_tests, test_action: :show)
  co.only :casespace, :assignments, :show
  run_tests_serializer(co)

end; end; end
