namespace :totem do

  # See '_doc/tests.md' for documentation.

  # Example: rake totem:test RAILS_ENV=test
  desc "Run totem tests"
  task :test => [:environment] do |t, args|
    engine_name = 'totem_test'
    print       = ::Totem::Core::Console::Print.new
    print.new_line
    print.error("Rails environment is #{::Rails.env.inspect} but must be \"test\".  Did you run with: rake thinkspace:test RAILS_ENV=test?") unless Rails.env.test?

    engine = ::Totem::Settings.engine.get_by_name(engine_name).first
    print.error("Did not find test engine #{engine_name.inspect}.  Did you include it in your Gemfile for Rails.env=#{::Rails.env.inspect}?") if engine.blank?

    print.line("Processing tests in engine #{engine_name.inspect}.", :cyan, :bold)
    helper = ::Totem::Test::Runner.new.process(engine, args.extras)
  end

end
