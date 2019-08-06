require 'serializer_asm10/test_helper'

module Test; module SerializerAsm10; class AbiiltyPerRecordTest < ActionController::TestCase
  include ::Thinkspace::Test::SerializerAsm10::All

  module ModuleIndexAbility
    def self.member_ability(serializer_options, record, ownerable)
      {test_a: true, test_b: false, id: record.id}
    end
  end

  def index_module_serializer_options
    ::Thinkspace::Common::Concerns::SerializerOptions::Spaces.class_eval do
      def index(serializer_options, scope)
        serializer_options.remove_all
        # ### add a module ability for each record ### #
        scope.records.each do |record|
          serializer_options.include_module_ability(module: ModuleIndexAbility, method: :member_ability, record: record)
        end
      end
    end
  end

  def assert_per_record_abilities(json)
    space_ids = (json.dig(:data) or []).collect {|h| h[:id].to_i}
    included  = json_included(json).select {|h| h['type'] == 'thinkspace/authorization/ability'}
    assert_equal true, included.length > 0, 'should have space ability'
    ability_ids = Array.new
    included.each do |ability|
      abilities = ability.dig(:attributes, :abilities)
      assert_abilities_values(abilities)
      ability_ids.push(abilities['id'])
    end
    assert_equal space_ids.sort, ability_ids.sort, "should have ability for each space"
  end

  add_test(Proc.new do |route|
    describe 'read_1 space index' do
      let(:user)      {read_1}
      let(:record)    {nil}
      let(:abilities) {get_test_abilities}
      before do; @route = route; end
      it 'include_ability' do
        index_module_serializer_options
        json = send_route_request
        assert_per_record_abilities(json)
      end
    end
  end) # proc

  co = new_route_config_options(tests: get_tests, test_action: :index)
  co.only :common, :spaces, :index
  run_tests_serializer(co)

end; end; end
