module Thinkspace::Test; module Casespace; module Json
extend ActiveSupport::Concern
included do

  def extract_json_users(hash, key=:first_name)
    primary_key = 'thinkspace/common/users'
    primary_key = 'thinkspace/common/user'  unless hash.has_key?(primary_key)
    actual      = extract_json(hash, primary_key, key)
    key == :first_name ? actual.map {|name| name.to_sym} : actual.flatten
  end

  def extract_json_spaces(hash, key=:title)
    primary_key = 'thinkspace/common/spaces'
    primary_key = 'thinkspace/common/space'  unless hash.has_key?(primary_key)
    actual      = extract_json(hash, primary_key, key)
    key == :title ? actual.map {|title| title.to_sym} : actual.flatten
  end

end; end; end; end
