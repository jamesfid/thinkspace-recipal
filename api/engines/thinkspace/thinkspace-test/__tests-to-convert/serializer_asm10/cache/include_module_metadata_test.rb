require 'serializer_asm10/test_helper'

module Test; module SerializerAsm10; class CacheIncludeModuleMetadataTest < ActionController::TestCase
  include ::Thinkspace::Test::SerializerAsm10::All

  add_test(Proc.new do |route|
    describe 'read_1 assignment show include module metadata' do
      let(:user)      {read_1}
      let(:record)    {serializer_assignment}
      before do; @route = route; end
      it 'not in cache key' do
        setup_cache_serializer_options
        serializer_options.cache(ownerable: user)
        serializer_options.include_module_metadata(module: ModuleMetadata, method: :member_metadata, record: record)
        json = send_route_request
        key  = cache_key(ownerable: user)
        refute_included_metadata_in_cache_key(json, key)
      end
    end
  end) # proc

  co = new_route_config_options(tests: get_tests, test_action: :show)
  co.only :casespace, :assignments, :show
  run_tests_serializer(co)

end; end; end
