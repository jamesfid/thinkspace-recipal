module Totem::Test::All
extend ActiveSupport::Concern
included do

  include ::Totem::Test::Ability::Assert
  include ::Totem::Test::Controllers
  include ::Totem::Test::Debug
  include ::Totem::Test::Json
  include ::Totem::Test::Models
  include ::Totem::Test::Routes
  include ::Totem::Test::Serialize
  include ::Totem::Test::Utility

  def self.get_tests; @tests; end

  def self.add_test(test)
    @tests ||= Array.new
    @tests.push(test)
  end

  def time_now; @time_now ||= Time.now.utc; end

end; end
