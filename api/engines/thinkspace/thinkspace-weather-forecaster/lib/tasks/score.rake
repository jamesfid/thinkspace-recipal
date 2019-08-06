require 'open-uri'

namespace :thinkspace do
  namespace :weather_forecaster do
    score = namespace :score do

      # CAUTION: NO SPACES ARE ALLOWED BETWEEN ARGUMENTS  right: [1,2,3]  wrong: [1, 2, 3]

      # alias for: rake thinkspace:weather_forecaster:score:authables[thinkspace/casespace/phase]
      task :phases do |t, args|
        score['authables'].invoke('thinkspace/casespace/phase', args.extras)
      end

      # ### Assessments.
      task :assessments do |t, args|
        score['call_process_method'].invoke(:process_assessments, args.extras)
      end

      # ### Forecasts.
      task :forecasts do |t, args|
        score['call_process_method'].invoke(:process_forecasts, args.extras)
      end

      # ### Items.
      task :items do |t, args|
        score['call_process_method'].invoke(:process_items, args.extras)
      end

      # ### Assessment_items.
      task :assessment_items do |t, args|
        score['call_process_method'].invoke(:process_assessment_items, args.extras)
      end

      # ### Responses.
      task :responses do |t, args|
        score['call_process_method'].invoke(:process_responses, args.extras)
      end

      # ### Authables.
      task :authables do |t, args|
        score['call_process_method'].invoke(:process_authables, args.extras)
      end

      # ### Dumps.
      task :dump, [] => [:environment] do |t, args|
        assessment_id = ENV['ASSESSMENT_ID']
        file_name     = ENV['FILE_NAME']
        raise         "No assessment_id passed in, cannot continue." unless assessment_id.present?
        raise         "No file name passed in, cannot continue." unless file_name.present?
        assessment    = ::Thinkspace::WeatherForecaster::Assessment.find_by(id: assessment_id)
        raise         "Invalid assessment for id: [#{assessment_id}]" unless assessment.present?
        space         = assessment.authable.get_space
        users         = space.thinkspace_common_users # Rows
        days          = ::Thinkspace::WeatherForecaster::ForecastDay.all
        all_results   = []
        users.each do |user|
          results = []
          results.push user.last_name
          results.push user.first_name
          results.push user.email
          days.each do |day|
            forecast_at = day.forecast_at
            next unless forecast_at.present?
            forecast = ::Thinkspace::WeatherForecaster::Forecast.find_ownerable_day(user, forecast_at)
            if forecast.present?
              results.push forecast.score.to_s
            else
              results.push nil
            end
          end # /days each
          all_results.push results
        end

        CSV.open(file_name, 'wb') do |csv|
          all_results.each do |row|
            csv << row
          end
        end

        file                     = File.open(file_name)
        importer_file            = ::Thinkspace::Importer::File.new
        importer_file.attachment = file
        importer_file.save
        puts "Data for DWF dump saved at #{importer_file.url}"
        File.delete(file_name)
      end

      # ### Helper Tasks.

      task :call_process_method, [:call_method] => [:environment] do |t, args|
        score['score_process_class'].invoke
        @score_process_class.new.send args.call_method, args.extras
      end

      task :score_process_class do |t, args|
        @score_process_class ||= Thinkspace::WeatherForecaster::AutoScore::Process
      end

      # ### CRON Tasks.

      task :assessments_from_isu_api do |t, args|
        base_url      = 'http://meteor.geol.iastate.edu/fcst/'
        start_day     = Time.now - 6.days
        end_day       = Time.now - 4.days
        start_day_out = start_day.strftime('%Y%m%d')
        end_day_out   = end_day.strftime('%Y%m%d')
        start_day_arg = start_day.strftime('%Y-%m-%d')
        end_day_arg   = end_day.strftime('%Y-%m-%d')
        start_url     = base_url + start_day_out + '.out'
        end_url       = base_url + end_day_out + '.out'

        begin
          start_content = open(start_url).read
          end_content   = open(end_url).read
          score['call_process_method'].invoke(:process_assessments, ["#{start_day_arg}:#{end_day_arg}"])
        rescue OpenURI::HTTPError => e
          raise "The requested URL was not found on the server, error: [#{e}]"
        end
    
      end

    end
  end
end