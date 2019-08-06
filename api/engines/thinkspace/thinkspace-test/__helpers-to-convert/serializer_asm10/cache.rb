module Thinkspace::Test; module SerializerAsm10; module Cache
extend ActiveSupport::Concern
included do

  def controller_cache?; ::Rails.configuration.action_controller.perform_caching.present?; end
  def memory_store?;     ::Rails.configuration.cache_store == :memory_store; end

  def verify_test_environment_controller_cache
    return unless serializer_options.cache?
    return if controller_cache? && memory_store?
    message = "\n***\n"
    message += "  Testing cache serializer options but the test environment does not have cache memory store enabled! In config/environments/test.rb add:\n"
    message += "     config.action_controller.perform_caching = true\n"
    message += "     config.cache_store                       = :memory_store\n"
    message += "***\n"
    assert_equal true, false, message
  end

  def no_assignment_show_serializer_options
    ::Thinkspace::Casespace::Concerns::SerializerOptions::Assignments.class_eval do
      def show; end
    end
  end

  def setup_cache_serializer_options
    verify_test_environment_controller_cache
    no_assignment_show_serializer_options
    serializer_options.cache_query_key(name: 'test_cache_key')
  end

  def cache_key(options={}); @controller.send(:controller_cache_key, record, options); end

end; end; end; end
