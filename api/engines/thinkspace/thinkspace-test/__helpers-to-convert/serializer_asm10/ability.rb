module Thinkspace::Test; module SerializerAsm10; module Ability
extend ActiveSupport::Concern
included do

  def assert_model_abilities(json); assert_abilities_values(json_abilities(json)); end
  def refute_model_abilities(json); assert_nil json_abilities(json), 'abilities should not be in model attributes'; end

  def assert_included_ability(json)
    included = json_included(json).find {|h| h['type'] == 'thinkspace/authorization/ability'}
    assert_kind_of Hash, included, 'included ability should be a hash'
    abiilties = included.dig(:attributes, :abilities)
    assert_abilities_values(abilities)
    abilities
  end

  def assert_abilities_values(abilities)
    assert_kind_of Hash, abilities, 'abilities should be a hash'
    assert_equal true,   abilities[:test_a], 'test_a ability should be true'
    assert_equal false,  abilities[:test_b], 'test_b ability should be false'
  end

  def assert_included_ability_in_cache_key(json, key)
    assert_included_ability(json)
    assert_match /.*test_a/, key, '==> serializer options cache key should include ability values'
  end

  def refute_included_ability_in_cache_key(json, key)
    assert_included_ability(json)
    refute_match /.*test_a/, key, '==> serializer options cache key should not include ability values'
  end

  def assert_included_metadata(json)
    included = json_included(json).find {|h| h['type'] == 'thinkspace/authorization/metadata'}
    assert_kind_of Hash, included, 'included metadata should be a hash'
    metadata = included.dig(:attributes, :metadata)
    assert_kind_of Hash, metadata, 'included attributes.metadata should be a hash'
    assert_equal true, metadata.has_key?(:due_at), 'included metadata should have "due_at" key'
    metadata
  end

  def refute_included_metadata_in_cache_key(json, key)
    assert_included_metadata(json)
    refute_match /.*due_at/, key, '==> serializer options cache key should not include metadata values'
  end

  def json_abilities(json);  json_attributes(json).dig(:abilities); end
  def json_attributes(json); json.dig(:data, :attributes) || Hash.new; end
  def json_included(json);   json.dig(:included) || Array.new; end

  def get_test_abilities; {test_a: true, test_b: false}; end

  module ModuleAbility
    def self.member_ability(serializer_options, record, ownerable)
      {test_a: true, test_b: false}
    end
  end

  module ModuleMetadata
    def self.member_metadata(serializer_options, record, ownerable)
      {due_at: true}
    end
  end

end; end; end; end
