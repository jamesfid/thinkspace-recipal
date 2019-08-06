require File.expand_path('../totem_helper_module', __FILE__)

namespace :totem do

  db_namespace = namespace :db do

    # ### See '_doc/seeds.md' for :reset and :seed tasks environment options e.g. CONFIG=. ### #

    desc "Reset database"
    task :reset => [:environment] do |t, args|
      Rake::Task['db:reset'].invoke
      db_namespace['domain:load'].invoke  # load the domain models after the db:reset
      db_namespace['seed'].invoke
    end

    desc "Soft reset database"
    task :soft_reset => [:environment] do |t, args|
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      db_namespace['seed'].invoke
    end

    desc "Hard reset the production database"
    task :production_hard_reset => [:environment] do
      db_namespace[:production_migrate].invoke
      db_namespace[:production_seed].invoke
    end

    desc "Seed the database"
    task :seed => [:environment] do |t, args|
      Rake::Task['thinkspace:db:seed'].invoke
    end

  end

end
