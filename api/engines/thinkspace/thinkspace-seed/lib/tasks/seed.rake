namespace :thinkspace do

  # NOTE: Typically, the 'thinkspace:db:seed' task is not directly run (other than for testing), but is invoked via 'totem:db:reset'.

  # See '_doc/seed.md' for documentation.

  db_namespace = namespace :db do

    desc "Load Thinkspace engine seeds"
    task :seed => [:environment] do
      print       = ::Totem::Core::Console::Print.new
      engine_name = 'thinkspace_seed'
      engine      = ::Totem::Settings.engine.get_by_name(engine_name).first
      print.new_line
      print.error("Did not find seeds engine #{engine_name.inspect}.  Did you include it in your Gemfile for Rails.env=#{::Rails.env.inspect}?") if engine.blank?
      print.line("Processing seeds in engine #{engine_name.inspect}.", :cyan, :bold)
      seed = ::Totem::Settings.seed.loader(engine)
      ActiveRecord::Base.transaction do
        ::Thinkspace::Seed::Seed.new.process(seed)
      end
    end

  end

end
