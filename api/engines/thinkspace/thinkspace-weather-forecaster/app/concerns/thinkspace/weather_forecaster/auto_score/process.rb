module Thinkspace
  module WeatherForecaster
    module AutoScore

      # Auto score forecast respones.
      # See documentation at end of this file or run a rake task with [help].

      class Process
        # scopes
        attr_reader :scope_assessments
        attr_reader :scope_forecasts
        attr_reader :scope_assessment_items
        attr_reader :scope_responses
        # extract args
        attr_reader :arg_str
        attr_reader :arg_ids
        attr_reader :arg_days
        attr_reader :arg_rake_task
        # ids
        attr_reader :assessment_ids
        attr_reader :station_ids
        attr_reader :forecast_ids
        attr_reader :item_ids
        attr_reader :assessment_item_ids
        attr_reader :response_ids
        attr_reader :authable_ids
        attr_reader :authable_class
        # misc
        attr_reader :actual_forecast_days
        attr_reader :station_codes
        attr_reader :assessment_ids_scope_message
        # boolean related options
        attr_reader :rescore
        attr_reader :reload_actuals
        attr_reader :default_days
        attr_reader :show_help
        attr_reader :debug

        def initialize
          @verify          = false
          @quiet           = false
          @dry_run         = false
          @print_ids       = false
          @show_help       = false
          @rescore         = false
          @reload_actuals  = false
          @debug           = false
          @max_days        = 7
          @default_days    = 'days:1'
          @num_responses   = 0
          @total_responses = 0
          @station_ids     = Array.new
          @station_codes   = Array.new
          @scope_responses = response_class.all
        end

        # ###
        # ### Public Methods.
        # ###

        # ### Assessments.
        def process_assessments(args=nil)
          set_assessment_ids_for_assessments(args)
          process
        end

        # ### Forecasts.
        def process_forecasts(args=nil)
          set_assessment_ids_for_forecasts(args)
          process_assessments
        end

        # ### Items.
        def process_items(args=nil)
          set_assessment_ids_for_items(args)
          process_assessments
        end

        # ### Assessment Items.
        def process_assessment_items(args=nil)
          set_assessment_ids_for_assessment_items(args)
          process_assessments
        end

        # ### Responses.
        def process_responses(args=nil)
          set_assessment_ids_for_responses(args)
          process_assessments
        end

        # ### Authables.
        def process_authables(args=nil)
          set_assessment_ids_for_authable(args)
          process_assessments
        end

        # ### Private Methods.
        #
        private

        def process
          forecast_days = get_forecast_days(arg_days)
          print_run_values
          set_final_run_scopes
          process_forecast_days(forecast_days)
          print_total_responses
        end

        def set_final_run_scopes
          @scope_assessments = assessment_class.all  if scope_assessments.blank?
          @scope_forecasts   = forecast_class.all    if scope_forecasts.blank?
          if rescore?
            @scope_assessments = scope_assessments.to_rescore
            @scope_forecasts   = scope_forecasts.to_rescore
            confirm_rescore
          else
            @scope_assessments = scope_assessments.to_score
            @scope_forecasts   = scope_forecasts.to_score
          end
          @scope_assessments = scope_assessments.where(id: assessment_ids)       if assessment_ids.present?
          @scope_assessments = scope_assessments.where(station_id: station_ids)  if station_ids.present?
          stop_run "No assessments found with the run values."  if scope_assessments.blank?
          @scope_forecasts = scope_forecasts.where(id: forecast_ids)  if forecast_ids.present?
        end

        def process_forecast_days(forecast_days)
          assessment_class.transaction do
            begin
              assessments = scope_assessments.order(:station_id)
              forecast_days.each do |forecast_day|
                print_value(forecast_day_class.name, forecast_day.forecast_at.to_date.to_s(:db), '')
                assessments.each do |assessment|
                  forecast_day_actual = forecast_actuals_instance.process(forecast_day, assessment.station_id)
                  forecasts           = scope_forecasts.where(assessment_id: assessment.id, forecast_day_id: forecast_day.id)
                  auto_score_forecasts(forecasts, forecast_day_actual)
                end
                print_count(assessment_class, assessments)
              end
            rescue ProcessError, ProcessNonFatalError => e
              if e.is_a?(ProcessNonFatalError)
                # Continue processing the next forecast (currently all errors are: ProcessError).
              else
                raise e  # Re-raising the error to rollback db updates.
              end
            end
          end # transaction
        end

        def get_forecast_days(days)
          forecast_days = forecast_day_class.scope_by_days(days)
          if forecast_days.blank?
            print_run_values
            stop_run "No forecasts were submitted in the days selected."
          end
          @actual_forecast_days = forecast_days.map(&:forecast_at).sort  if forecast_days.length != days.length
          forecast_days
        end

        # #################################################################################################
        # ###
        # ### Auto-score Forecasts.
        # ###
        #
        def auto_score_forecasts(forecasts, forecast_day_actual)
          @num_responses = 0
          forecasts.each do |forecast|
            begin
              forecast.transaction do
                responses = scope_responses.where(forecast_id: forecast.id)
                auto_score_responses(responses, forecast_day_actual)
                update_forecast(forecast)
              end
            rescue ProcessError, ProcessNonFatalError => e
              if e.is_a?(ProcessNonFatalError)
                # Continue processing the next forecast (currently all errors are: ProcessError).
              else
                raise e  # Re-raising the error to rollback db updates.
              end
            end
          end
          print_count(forecast_class, forecasts, "  (responses: #{@num_responses})")
          @total_responses += @num_responses
        end

        def update_forecast(forecast)
          return if dry_run?
          forecast.set_locked
          forecast.score = forecast.sum_response_scores
          raise ProcessError, "Error saving forecast #{forecast.inspect}."  unless forecast.save
        end

        def auto_score_responses(responses, forecast_day_actual)
          responses.each do |response|
            score_response(response, forecast_day_actual)
          end
        end

        def score_response(response, forecast_day_actual)
          return if response.blank?
          @num_responses += 1
          score = response.calculate_score(common_instance_initialize_options.merge(forecast_day_actual: forecast_day_actual))
          return if dry_run?
          response_score = response.find_or_create_response_score
          raise ProcessError, "Response [id: #{response.id}] response score is blank." if response_score.blank?
          response_score.score = score
          raise ProcessError, "Error saving response score [id: #{response_score.id}]." unless response_score.save
        end
        #
        # #################################################################################################

        # ###
        # ### Scopes and set Assessment Ids.
        # ###

        def set_assessment_ids_for_assessments(args)
          return if assessment_ids.present?  # args extracted and set via another rake task e.g. forecasts, items, etc.
          extract_and_validate_args(assessment_class, args)
          @assessment_ids               = arg_ids
          @assessment_ids_scope_message = 'all assessments'  if assessment_ids.blank?
        end

        def set_assessment_ids_for_forecasts(args)
          extract_and_validate_args(forecast_class, args)
          @forecast_ids = arg_ids
          scope         = forecast_ids.present? ? forecast_class.where(id: forecast_ids) : forecast_class.all
          scope         = scope.scope_by_days(arg_days)  if arg_days.present?
          if scope.blank?
            print_run_values
            stop_run "No forecasts found for the run values."
          end
          @assessment_ids = scope.pluck(:assessment_id).uniq
          stop_run "No assessments found for forecast ids: #{forecast_ids}."  if assessment_ids.blank?
          @assessment_ids_scope_message = 'all forecast assessments'     if forecast_ids.blank?
        end

        def set_assessment_ids_for_items(args)
          extract_and_validate_args(item_class, args)
          @item_ids            = arg_ids
          @assessment_item_ids = assessment_item_class.where(item_id: arg_ids).pluck(:id).uniq
          @assessment_ids      = assessment_class.scope_by_assessment_item_ids(assessment_item_ids).pluck(:id).uniq
          stop_run "No assessments found for item ids: #{item_ids} -> assessment item ids: #{assessment_item_ids}."  if assessment_ids.blank?
          @scope_responses = scope_responses.where(assessment_item_id: assessment_item_ids)
        end

        def set_assessment_ids_for_assessment_items(args)
          extract_and_validate_args(assessment_item_class, args)
          @assessment_item_ids = arg_ids
          @assessment_ids      = assessment_class.scope_by_assessment_item_ids(assessment_item_ids).pluck(:id).uniq
          stop_run "No assessments found for assessment item ids: #{assessment_item_ids}."  if assessment_ids.blank?
          @scope_responses = scope_responses.where(assessment_item_id: assessment_item_ids)
        end

        def set_assessment_ids_for_responses(args)
          extract_and_validate_args(response_class, args)
          @response_ids = arg_ids
          stop_run "Response ids blank."  if response_ids.blank?
          @scope_responses = scope_responses.where(id: response_ids)
          @assessment_item_ids = scope_responses.pluck(:assessment_item_id).uniq
          stop_run "No assessment items found for response ids: #{response_ids}."  if assessment_item_ids.blank?
          @assessment_ids = assessment_class.scope_by_assessment_item_ids(assessment_item_ids).pluck(:id).uniq
          stop_run "No assessments found for response ids: #{response_ids}."  if assessment_ids.blank?
          @forecast_ids = forecast_class.scope_by_response_ids(response_ids).pluck(:id).uniq
          stop_run "No forecasts found for response ids: #{response_ids}."  if forecast_ids.blank?
          @scope_forecasts = forecast_class.where(id: forecast_ids)
        end

        def set_assessment_ids_for_authable(args)
          args          = [args].flatten
          authable_type = args.shift
          stop_run "Authable class is blank. Provide the class path or string as the first argument."  if authable_type.blank?
          @authable_class = authable_type.classify.safe_constantize
          stop_run "Authable type #{authable_type.inspect} could not be constantized."  if authable_class.blank?
          extract_and_validate_args(authable_class, args)
          @authable_ids   = arg_ids
          @assessment_ids = assessment_class.where(authable_type: authable_class.name, authable_id: authable_ids).pluck(:id).uniq
          stop_run "No assessments found for authable #{authable_class.name} ids: #{authable_ids}."  if assessment_ids.blank?
        end

        # ###
        # ### Helper Class Instances.
        # ###

        def forecast_actuals_instance
          @forecast_actual_instance ||= AutoScore::ForecastActuals.new(common_instance_initialize_options)
        end

        def common_instance_initialize_options
          @common_instance_initialize_options ||= {
            reload_actuals:        reload_actuals?,
            dry_run:               dry_run?,
            debug:                 debug?,
            quiet:                 quiet?,
            error_class:           ProcessError,
            non_fatal_error_class: ProcessNonFatalError,
          }
        end

        # ###
        # ### Extract Args.
        # ###

        def extract_and_validate_args(klass, args)
          @arg_rake_task = klass.name.demodulize.downcase.pluralize
          args = [args].flatten.compact.collect {|v| v.strip}
          if args.blank?
            @arg_days = validate_dates_into_day_times(default_days) if arg_days.blank?
            return
          end
          @arg_str   = args.join(',')
          ids, dates = get_ids_and_dates(args)
          dates      = dates.push(default_days) if dates.blank?
          @arg_ids   = validate_ids(klass, ids)
          @arg_days  = validate_dates_into_day_times(dates)
          if arg_days.length > @max_days
            message  = "The number days selected (#{arg_days.length}) is over the maximum allowed of #{@max_days}."
            message += "  If the number of days is correct, use the arg 'max_days:#' to override."
            stop_run message
          end
        end

        def get_ids_and_dates(args)
          ids   = Array.new
          dates = Array.new
          args.each do |arg|
            arg = arg.to_s
            case
            when is_digits?(arg)               then ids.push(arg.to_i)
            when arg.match(/\d+-\d+-\d+/)      then dates.push(arg)
            when arg.start_with?('days:')      then dates.push(arg)
            when arg == 'day'                  then dates.push('days:1')
            else
              stop_run "Invalid argument #{arg.inspect}."  unless valid_run_option_arg(arg)
            end
          end
          [ids, dates]
        end

        def valid_run_option_arg(arg)
          case arg.downcase
            when 'rescore'                        then @rescore = true
            when 'verify', 'v'                    then @verify = true
            when 'quiet', 'q'                     then @quiet = true
            when 'dry_run', 'dry-run', 'd'        then @dry_run = true
            when 'print_ids', 'print-ids', 'p'    then @print_ids = true
            when 'debug'                          then @debug = true
            when 'reload_actuals'                 then @reload_actuals = true
            when 'help', 'h'                      then @show_help = true
            else
              case
              when arg.start_with?('max_days:') || arg.start_with?('max-days:') || arg.start_with?('m:')
                days = get_arg_value(arg) || ''
                return false unless is_digits?(days)
                @max_days = days.to_i
              when arg.start_with?('station:')
                code = get_arg_value(arg) || ''
                return false unless code.length == 4 && code.match(/^\w+$/)
                add_station_id(code)
              else
                false
              end
            end
        end

        def validate_ids(klass, ids)
          ids.each do |id|
            record = klass.find_by(id: id)
            stop_run "Record '#{klass.name} id:#{id}' not found."  if record.blank?
          end
          ids
        end

        def validate_dates_into_day_times(dates)
          days = Array.new
          [dates].flatten.each do |date|
            days.push convert_date_value(date)
          end
          [days].flatten.compact.uniq.sort
        end

        def convert_date_value(date)
          case
          when date.start_with?('days:')
            t, days = date.split(':',2)
            stop_run "Number of days in #{date.inspect} is not numeric."  unless days.match(/^\d+$/)
            start_date = get_current_day - days.to_i.days
            end_date   = get_current_day - 1.day
            get_days_between_dates(start_date.to_s, end_date.to_s)
          when date.end_with?(':')
            end_date = get_current_day - 1.day
            get_days_between_dates(date, end_date.to_s)
          when date.match(':')
            start_date, end_date = date.split(':',2)
            get_days_between_dates(start_date, end_date)
          else
            get_time_from_date_string(date)
          end
        end

        def get_current_day; forecast_day_class.get_current_day; end

        def get_days_between_dates(start_date, end_date)
          all_days   = Array.new
          start_date = get_time_from_date_string(start_date)
          end_date   = get_time_from_date_string(end_date)
          stop_run "Starting date #{start_date.to_date.inspect} greater than end date #{end_date.to_date.inspect}."  if start_date > end_date
          days = end_date.to_date - start_date.to_date
          days += 1 # include the end date
          days.to_i.times do |i|
            all_days.push start_date + i.days
          end
          all_days
        end

        def get_time_from_date_string(date)
          begin
            time = Time.parse(date)
          rescue ArgumentError
            stop_run "Invalid date #{date.inspect}.  Must be in format 'YYYY-MM-DD'."
          end
          forecast_day_class.get_day(time)
        end

        def add_station_id(code)
          station = station_class.where('LOWER(location) = ?', code.downcase)
          stop_run "Station location #{code.inspect} not found (case insensitive search)." if station.blank?
          stop_run "Station location #{code.inspect} returned #{station.length} stations (case insensitive search)." if station.length != 1
          station = station.first
          station_ids.push(station.id)
          station_codes.push(station.location)
        end

        # ###
        # ### Helpers.
        # ###

        def get_arg_value(arg)
          return nil if arg.blank?
          arg.split(':',2).last
        end

        def is_digits?(arg)
          return false if arg.blank?
          arg.match(/^\d+$/)
        end

        def print_run_values(message='')
          return if quiet?
          puts "\nRun values:"
          puts '   This is a DRY RUN!'  if dry_run?
          puts '   Run is a RESCORE!'   if rescore?
          print_value 'Rake task',                 (arg_rake_task || '').inspect, ''
          print_value 'Argument string',           (arg_str || '').inspect, ''
          print_value assessment_class.name,       assessment_ids_scope_message || assessment_ids
          print_value forecast_class.name,         forecast_ids
          print_value item_class.name,             item_ids
          print_value assessment_item_class.name,  assessment_item_ids
          print_value response_class.name,         response_ids
          print_value authable_class.name,         authable_ids  if authable_class.present?
          print_value station_class.name,          station_codes, '.location'
          print_value 'Selected forecast days',    (arg_days || []).map {|d| d.to_date.to_s(:db)}, ''
          print_value 'Actual days with forecsts', actual_forecast_days.map {|d| d.to_date.to_s(:db)}, ''  if actual_forecast_days.present?
          puts ''
          if show_help
            print_help
            stop_run
          end
          ask_yes 'Continue with these run values?'  if verify? && !rescore?
        end

        def print_value(text, values, sub_text='.id', post_text='')
          return if values.blank?
          len = 56
          puts "   #{text}#{sub_text}".ljust(len) + ": #{values}" + post_text
        end

        def print_count(klass, array, text='')
          return if quiet?
          name = klass.name
          if print_ids? && array.length > 0
            ids  = array.map(&:id)
            text = text.ljust(20)  if text.present?
            text += "  ids: #{ids}"
          end
          count   = array.length.to_s.rjust(5)
          message = "   #{name}".ljust(55) + ' ids-count: ' + count + text
          puts message
        end

        def print_total_responses
          return if quiet?
          puts "Total responses processed: #{@total_responses}"
        end

        def confirm_rescore
          ask_yes "\nDo you really want to perform a 'rescore' with these run values?" if verify?
        end

        def ask_yes(message='')
          puts message + ' (yes/no)'
          answer = STDIN.gets.chomp
          stop_run unless (answer.present? && answer.downcase == 'yes')
        end

        def stop_run(message='')
          puts "\n"
          puts ">> Run stopped [#{Time.now.to_s(:db)}]. " + message
          puts "\n"
          exit
        end

        def quiet?;            @quiet.present?; end
        def verify?;           @verify.present?; end
        def print_ids?;        @print_ids.present?; end
        def dry_run?;          @dry_run.present?; end
        def rescore?;          @rescore.present?; end
        def reload_actuals?;   @reload_actuals.present?; end
        def debug?;            @debug.present?; end

        def item_class;                Thinkspace::WeatherForecaster::Item; end
        def forecast_day_class;        Thinkspace::WeatherForecaster::ForecastDay; end
        def assessment_class;          Thinkspace::WeatherForecaster::Assessment; end
        def assessment_item_class;     Thinkspace::WeatherForecaster::AssessmentItem; end
        def forecast_class;            Thinkspace::WeatherForecaster::Forecast; end
        def response_class;            Thinkspace::WeatherForecaster::Response; end
        def station_class;             Thinkspace::WeatherForecaster::Station; end

        class ProcessError         < StandardError; end
        class ProcessNonFatalError < StandardError; end

        # ###
        # ### Help Doc.
        # ###

        def print_help
          help = <<HELP
Run help:
  CAUTION: FOR RAKE TASKS, NO SPACES ARE ALLOWED BETWEEN ARGUMENTS  right: [1,2,3]  wrong: [1, 2, 3]

  Overview:
    Every run scopes the assessments and forecasts according to the run values.  If use a rake task other then
    'assessments' or 'forecasts', the task model will also be scoped e.g. item.id == 1.

  Rake task options:
    * options can be in any order in the argument string (execpt authables where the class path must be the first argument)
    [#,#,...]:              : record ids for the main run class e.g assessments, forecasts, authables, etc.
    [YYYY-MM-DD]            : day to scope the forecasts
    [YYYY-MM-DD:]           : e.g. date ending in a colon; days calculated by start day up to and including the current day
    [YYYY-MM-DD:YYYY-MM-DD] : day ranage including the start day and end day
    [day]                   : previous day before the current day (alias for 'days:1')
    [days:#]                : (default #{default_days.inspect}) number of days before the current day

    WARNING: If a date or date-range is used, the current day will be scored if the current day is in the range (or date is the current day).
             Use 'days:#' type argument to make sure the current day is not included.

    [max_days:#|max-days:#|m:#] : (default #{@max_days}); to help prevent a typeo, the number of days selected is checked against the max days allowed
                                : and if over the maximum the run is stopped
                                : If you know the run will be over the default, override the max days with this option.

    [station:code]              : scope the assessments to the station code (four character/number station location)
                                : can be used multiple times e.g. [station:abcd,station:wxyz]

    Boolean options (default false):           
      [rescore]               : use the rescore scopes e.g. forecast state 'locked'
      [reload_actuals]        : reload and update/create the forecast day actuals from a file e.g. updates the actuals if already exist
                                (by default, they are only created when a forecast_day_actual record does not exist)
      [verify|v]              : prompt to verify the run values
      [quiet|q]               : do not print any status information
      [print_ids|print-ids|p] : print a list of ids after the status message
      [dry_run|dry-run|d]     : perform a dry run
      [debug]                 : set debug on; mainly for the AutoScore::Response class

  Tasks
    thinkspace:weather_forecaster:score:assessments       #=> all assessments unless ids present; date options are applied to the forecasts
    thinkspace:weather_forecaster:score:forecasts         #=> all forecasts unless ids present
    thinkspace:weather_forecaster:score:items             #=> item ids -> assessment item ids (for all forecasts) to score
    thinkspace:weather_forecaster:score:assessment_items  #=> assessment item ids to score
    thinkspace:weather_forecaster:score:authables         #=> authable ids used to find assessment ids to score
    thinkspace:weather_forecaster:score:phases            #=> alias for authables by passing in the phase class path
    thinkspace:weather_forecaster:score:responses         #=> score specific response ids (very narrow scope; id(s) must also be in the day scope)

  Tasks: assessments vs forecasts
    No difference between running tasks 'assessments' vs 'forecasts' unless want to specifiy ids.
    Ids for the 'assessments' task will scope the assessment ids, while ids for the 'forecasts' task scopes forecast ids.

    However, other tasks (items, assessment_items, authables, phases, responses) require an ID to scope the assessments and forecasts.

  Forecast states (scopes: 'to_score' vs 'to_rescore):
    * 'to_score'   : scoped to state='completed'              (no rescore option)
    * 'to_rescore' : scoped to state='completed' or 'locked'  (with rescore option)
    * state='unlocked' (e.g. not submitted), are not scored.

  Examples:

   rake thinkspace:weather_forecaster:score:asessments         #=> score all assessments and forecasts for the previous day
   rake thinkspace:weather_forecaster:score:asessments[day]    #=> same as above
   rake thinkspace:weather_forecaster:score:asessments[days:1] #=> same as above
   rake thinkspace:weather_forecaster:score:forecasts          #=> all forecasts for the previous day

    thinkspace:weather_forecaster:score:assessments[rescore]        #=> rescore all assessment forecasts
   rake thinkspace:weather_forecaster:score:assessments[1,days:2]   #=> score the forecasts for 'assessment' id 1 for the previous 2 days
   rake thinkspace:weather_forecaster:score:forecasts[1,days:2]     #=> score the forecasts for 'forecast' id 1 for the previous 2 days

   rake thinkspace:weather_forecaster:score:assessments[2015-06-01]             #=> score forecasts for 2015-06-01
   rake thinkspace:weather_forecaster:score:assessments[2015-06-01:]            #=> score forecasts for 2015-06-01 through (current-day - 1.day)
   rake thinkspace:weather_forecaster:score:assessments[2015-06-01:2015-06-03]  #=> score forecasts for 2015-06-01, 2015-06-02, 2015-06-03

   rake thinkspace:weather_forecaster:score:authables[thinspace/casespace/phase,1] #=> get the assessment id(s) related to phase id 1 and process
                                                                                       the assessments for the previous day
   rake thinkspace:weather_forecaster:score:phases[1] #=> same as above

  Ids and boolean options can be anywhere in the argument string.
   rake thinkspace:weather_forecaster:score:assessments[1,p,d,days:2,9,verify]
     * score the forecasts for assessment ids [1, 9] for the previous 2 days (in a completed state)
     * perform a dry run; verify run values before processing; print the ids

  Running Real-Time (e.g. via UI)
   The arguments for each public method is an array of values (e.g. [1, 2, 'days:3', ...]) so this class
   could be instantiated outside of a rake task and the appropriate public method called with an argument array.
HELP
          puts help
        end
      end

    end
  end
end
