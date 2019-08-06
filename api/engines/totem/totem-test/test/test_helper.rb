require ::Rails.root.join('config', 'environments', "#{::Rails.env}.rb")

require 'rails/test_help'
require 'minitest/spec'
require 'minitest/mock'

class ActiveSupport::TestCase

  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  extend MiniTest::Spec::DSL

  # Register the type of describe description that should use an ActiveSupport::TestCase.
  # activesupport-4.0.3/lib/active_support/test_case.rb inherits from MiniTest.
  # e.g. ActiveSupport::TestCase < ::MiniTest::Unit::TestCase
  # ActiveSupport::TestCase adds extra functionality like better 'test' logging
  # and addition matchers.
  register_spec_type(self) do |desc|
    if desc.is_a?(Class)
      desc < ActiveRecord::Base
    elsif desc.is_a?(String)  # when a string, use an ActiveSupport::TestCase
      true
    else
      false
    end
  end

  # Add more helper methods to be used by all tests here...
end
