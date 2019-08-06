module Thinkspace; module Migrate; module ToComponents; module Inspect
  class Teams < Totem::DbMigrate::BaseHelper
    require 'pp'

    def process
      teams        = old_team_class.all
      no_authables = teams.where(authable_id: nil)
      puts "Teams total count: #{teams.count}"
      puts "Teams without an authable: #{no_authables.length}"
      puts "\n"
      puts "Teams without authables:"
      print_team_authables(no_authables)
      puts "\n"
      puts "Teams with authable:"
      print_team_authables teams.where.not(authable_id: nil)
    end

    def print_team_authables(teams)
      no_teamables = Array.new
      teams.order(:id).each do |team|
        teamable = old_team_teamable_class.find_by(team_id: team.id)
        message  = "team id: #{team.id.to_s.rjust(4)}   authable: #{team.authable_type.inspect.ljust(30)}  title: #{team.title.inspect.ljust(30)}"
        message += teamable.blank? ? '---NO TEAMABLE---' : "#{teamable.teamable_type}.#{teamable.teamable_id}"
        puts message
        no_teamables.push(team)  if teamable.blank? && team.authable_type.blank?
      end
      puts "\n"
      if no_teamables.present?
        puts "NO TEAMABLES:"
        no_teamables.each do |team|
          puts "team id: #{team.id.to_s.rjust(4)}   authable: #{team.authable_type.inspect.ljust(30)}  title: #{team.title.inspect.ljust(30)}"
        end
      else
        puts "All teams have an authable or teamable"
      end
    end

    def old_team_class;    get_old_model_class('thinkspace/team/team'); end
    def old_team_teamable_class; get_old_model_class('thinkspace/team/team_teamable'); end

  end
  
end; end; end; end

