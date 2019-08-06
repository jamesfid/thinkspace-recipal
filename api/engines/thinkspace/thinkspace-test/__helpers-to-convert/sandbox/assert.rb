module Thinkspace::Test; module Sandbox; module Assert
extend ActiveSupport::Concern
included do

  def assert_space_assignment_ids(json, space, assignments=[])
    ids  = [assignments].flatten.compact.map(&:id).sort
    hash = json.dig('data')
    assert_json_assignment_association_ids(hash, ids)
    assert_json_space_id(hash, space)
  end

  def assert_assignment_space_id(json, space, assignment=nil)
    hash = json.dig('data')
    assert_json_assignment_id(hash, assignment) if assignment.present?
    assert_json_space_association_id(hash, space)
  end

  def assert_assignments_space_id(json, spaces, assignments=[])
    spaces      = [spaces].flatten.compact.sort_by {|s| s.id}
    assignments = [assignments].flatten.compact.sort_by {|a| a.id}
    assignments_json(json).each_with_index do |hash, index|
      assert_json_assignment_id(hash, assignments[index]) if assignments.present?
      assert_json_space_association_id(hash, spaces[index])
    end
  end

  def assert_json_assignment_id(hash, assignment)
    assert_equal true, hash.is_a?(Hash), 'assigment hash is a Hash'
    id = hash.dig('id')
    id = id.to_i if id
    assert_equal assignment.id, id, "Should have correct user's assignment id"
  end

  def assert_json_assignment_association_ids(hash, ids)
    relationships  = hash.dig('relationships', json_assignment_key.pluralize, 'data') || []
    assignment_ids = relationships.map {|r| (r.dig('id') || 0).to_i}.sort
    assert_equal ids, assignment_ids, "Should have correct assignment association ids"
  end

  def assert_json_space_id(hash, space)
    assert_equal true, hash.is_a?(Hash), 'space hash is a Hash'
    id = hash.dig('id')
    id = id.to_i if id
    assert_equal space.id, id, "Should have correct user's space id"
  end

  def assert_json_space_association_id(hash, space)
    assert_equal true, hash.is_a?(Hash), 'space associations hash is a Hash'
    id = hash.dig('relationships', json_space_key, 'data', 'id')
    id = id.to_i if id
    assert_equal space.id, id, "Should have correct user's space association id"
  end

  def json_space_key;       space_class.name.underscore; end
  def json_assignment_key;  assignment_class.name.underscore; end
  def json_space_key;       space_class.name.underscore; end

  def assignments_json(json); (json.dig('data') || []).sort_by {|h| h['id']}; end

end; end; end; end
