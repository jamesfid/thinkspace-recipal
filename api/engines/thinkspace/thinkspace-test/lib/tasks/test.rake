namespace :thinkspace do

  # See '_doc/tests.md' for documentation.

  # Example: rails thinkspace:test RAILS_ENV=test SEED=true
  desc "Run thinkspace tests"
  task :test => [:environment] do |t, args|
    db_name     = 'thinkspace_test'
    engine_name = 'thinkspace_test'
    print       = ::Totem::Core::Console::Print.new
    print.new_line
    print.error("Rails environment is #{::Rails.env.inspect} but must be \"test\".  Did you run with: rake thinkspace:test RAILS_ENV=test?") unless Rails.env.test?

    db = ::Rails.application.secrets.totem_database['name']
    print.error("Database name is not #{db_name.inspect} but is #{db.inspect}.  Did you 'source .env-test'?") unless db == db_name

    engine = ::Totem::Settings.engine.get_by_name(engine_name).first
    print.error("Did not find test engine #{engine_name.inspect}.  Did you include it in your Gemfile for Rails.env=#{::Rails.env.inspect}?") if engine.blank?

    print.line("Processing tests in engine #{engine_name.inspect}.", :cyan, :bold)
    helper = ::Totem::Test::Runner.new.process(engine, args.extras)
  end

end
