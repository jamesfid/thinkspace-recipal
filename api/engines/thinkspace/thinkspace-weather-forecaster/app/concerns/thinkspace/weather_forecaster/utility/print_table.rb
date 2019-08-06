module Thinkspace
  module WeatherForecaster
    module Utility

      # Print Table records.  Mainly for Item and/or AssessmentItem record columns.
      # See documentation at end of this file or run a rake task with [help].

      require 'pp'
      begin
        require 'awesome_print'
      rescue LoadError
      end

      class PrintTable

        attr_reader :run_class
        attr_reader :run_scope

        attr_reader :arg_ids
        attr_reader :arg_order
        attr_reader :arg_scopes
        attr_reader :arg_str

        attr_reader :ap_options
        attr_reader :column_names
        attr_reader :show_help

        attr_reader :indent
        attr_reader :print_method
        attr_reader :compare_dup

        def initialize
          @arg_ids      = Array.new
          @arg_order    = Array.new
          @arg_scopes   = Array.new
          @show_help    = false
          @indent       = 3
          @print_method = :pp
          @compare_dup  = false
          @ap_sort_keys = true
          @ap_options   = {index: false, indent: 3}
        end

        # ###
        # ### Supported Tables.
        # ###
        def item_class;                Thinkspace::WeatherForecaster::Item; end
        def assessment_item_class;     Thinkspace::WeatherForecaster::AssessmentItem; end
        def station_class;             Thinkspace::WeatherForecaster::Station; end
        def assessment_class;          Thinkspace::WeatherForecaster::Assessment; end
        def forecast_class;            Thinkspace::WeatherForecaster::Forecast; end
        def forecast_day_class;        Thinkspace::WeatherForecaster::ForecastDay; end
        def forecast_day_actual_class; Thinkspace::WeatherForecaster::ForecastDayActual; end
        def response_class;            Thinkspace::WeatherForecaster::Response; end
        def response_score_class;      Thinkspace::WeatherForecaster::ResponseScore; end

        def all(args=nil)
          @ap_sort_keys = false
          extract_and_validate_args(args)
          puts "Task 'all' has column names but they will be ignored (use task 'columns' if want a column based print)." if column_names.present?
          run_scope.each do |item|
            print_sep :all, item
            print_item item
          end
        end

        def columns(args=nil)
          extract_and_validate_args(args)
          stop_run "No column names specified in arguments e.g. [processing,response_metadata]"  if column_names.blank?
          run_scope.each do |item|
            print_sep :columns, item
            print_columns(item)
          end
        end

        def compare(args=nil)
          extract_and_validate_args(args)
          if run_class == item_class
            compare_dup ? compare_items_dup : compare_items_no_dup
          else
            compare_dup ? compare_assessment_items_dup : stop_run("Compare with no dups on assessment item class not supported.")
          end
        end

        def compare_items_dup
          run_scope.each do |item|
            item.thinkspace_weather_forecaster_assessment_items.each do |assessment_item|
              print_sep "compare #{get_item_text(item)} ==>", assessment_item
              print_columns item, get_item_text(item)
              print_columns assessment_item, get_item_text(assessment_item)
            end
          end
        end

        def compare_assessment_items_dup
          run_scope.each do |assessment_item|
            item = assessment_item.thinkspace_weather_forecaster_item
            print_sep "compare #{get_item_text(assessment_item)} ==>", item
            print_columns assessment_item, get_item_text(assessment_item)
            print_columns item, get_item_text(item)
          end
        end

        # Print the 'item' data once followed by the assessment items (less print but harder to compare).
        def compare_items_no_dup
          run_scope.each do |item|
            print_sep :compare, item
            print_columns(item)
            item.thinkspace_weather_forecaster_assessment_items.each do |assessment_item|
              print_sep "---AssessmentItem.id:#{assessment_item.id} ==>", item
              print_columns(assessment_item)
            end
          end
        end

        # ###
        # ### Helpers.
        # ###

          # @compare_dup           = options.has_key?(:compare_dup) ? options.delete(:compare_dup) : true

        def extract_and_validate_args(args)
          args       = [args].flatten.compact.collect {|v| v.strip}
          @arg_str   = args.join(',')
          args       = set_run_class(args)
          args       = set_run_scope(args)
          args       = set_column_names(args)
          args       = set_print_options(args)
          @show_help = true  if args.include?('help') || args.include?('h')
          print_run_values
        end

        def set_run_class(args)
          valid = Array.new
          klass = nil
          args.each do |arg|
            case arg
            when 'item'                then klass = item_class
            when 'assessment_item'     then klass = assessment_item_class
            when 'station'             then klass = station_class
            when 'assessment'          then klass = assessment_class
            when 'forecast'            then klass = forecast_class
            when 'forecast_day'        then klass = forecast_day_class
            when 'forecast_day_actual' then klass = forecast_day_actual_class
            when 'response'            then klass = response_class
            end
            if klass.present?
              valid.push(arg)
              break
            end
          end
          @run_class = klass || item_class
          args - valid
        end

        def set_run_scope(args)
          scope = run_class.all
          valid = Array.new
          args.each do |arg|
            key, value = get_arg_values(arg)
            case key
            when 'order', 'o'
              order       = get_arg_values(arg).last
              order, sort = get_arg_values(order)
              order       = "#{order} #{sort}"  if sort.present?
              arg_order.push(order)
              valid.push(arg)
            when 'offset'
              num   = get_arg_number(arg)
              scope = scope.offset(num)
              valid.push(arg)
              arg_scopes.push("offset(#{num})")
            when 'limit', 'l'
              num   = get_arg_number(arg)
              scope = scope.limit(num)
              valid.push(arg)
              arg_scopes.push("limit(#{num})")
            else
              if is_digits?(arg)
                arg_ids.push(arg)
                valid.push(arg)
              end
            end
          end
          scope      = scope.where(id: arg_ids)  if arg_ids.present?
          scope      = scope.order(arg_order)    if arg_order.present?
          @run_scope = scope
          args - valid
        end

        def set_column_names(args)
          class_columns = run_class.column_names
          columns       = Array.new
          args.each do |arg|
            case arg
            when 'rm'      then columns.push(:response_metadata)
            when 'pr'      then columns.push(:processing)
            when 'rmpr'    then columns.push(:response_metadata, :processing)
            when 'p'       then columns.push(:presentation)
            when 'ht'      then columns.push(:help_tip)
            when 'ih'      then columns.push(:item_header)
            when 'v'       then columns.push(:value)
            else
              columns.push(arg.to_sym) if class_columns.include?(arg)
            end
          end
          @column_names = columns.uniq
          args - class_columns
        end

        def set_print_options(args)
          valid = Array.new
          args.each do |arg|
            case arg
            when 'dup'
              @compare_dup = true
              valid.push(arg)
            when 'ap'
              if self.respond_to?(:ap, true)
                @print_method = :ap
              else
                puts "Warning: awesome_print gem is not available.  Defaulting to 'pp'."
              end
              valid.push(arg)
            when 'plain', 'no_color', 'no-color'
              @ap_options[:plain] = true
              valid.push(arg)
            when 'index'
              @ap_options[:index] = true
              valid.push(arg)
            when 'sort_keys', 'sort-keys', 'sk'
              @ap_options[:sort_keys] = true
              valid.push(arg)
            when 'no_sort_keys', 'no-sort-keys', 'nsk'
              @ap_options[:sort_keys] = false
              valid.push(arg)
            else
              key, value = get_arg_values(arg)
              if key == 'indent'
                @ap_options[:indent] = get_arg_number(arg)
                valid.push(arg)
              end
            end
          end
          if print_method == :ap
            ap_options[:sort_keys] = @ap_sort_keys  unless ap_options.has_key?(:sort_keys)
          end
          args - valid
        end

        def get_arg_values(arg); arg.split(':',2); end

        def get_arg_number(arg)
          key, value = get_arg_values(arg)
          stop_run "Arg #{arg.inspect} must have a number value not #{value.inspect}." unless is_digits?(value)
          value.to_i
        end

        def is_digits?(arg)
          return false if arg.blank?
          arg.match(/^\d+$/)
        end

        # ###
        # ### Print Helpers.
        # ###

        def print_run_values
          puts "\nRun values:"
          print_value 'Class',        run_class.name
          print_value 'Arg string',   (arg_str || '').inspect
          print_value 'Ids',          arg_ids
          print_value 'Order',        arg_order
          print_value 'Columns',      (column_names || []).map{|n| n.to_s}
          print_value 'ap options',   ap_options.inspect  if print_method == :ap
          print_value 'Scopes',       arg_scopes
          if show_help
            print_help
            stop_run
          end
        end

        def print_value(text, values, sub_text='')
          return if values.blank?
          len = 20
          puts "   #{text}#{sub_text}".ljust(len) + ": #{values}"
        end

        def get_item_text(item)
          "#{item.class.name.demodulize}.id:#{item.id}"
        end

        def print_columns(item, text='')
          if column_names.blank?
            print_item item
          else
            column_names.each do |col|
              print_column_header(col, text)
              print_item item[col]
            end
          end
        end

        def print_column_header(col, text='')
          len  = 25
          text = text.present? ? " --#{text}".ljust(len, '-') : '-'.ljust(len, '-')
          puts text + "> #{col}:"
        end

        def print_item(object)
          print_method == :ap ? ap(object, ap_options) : pp(object)
        end

        def print_sep(description, item)
          sep = "#{description} #{get_item_text(item)} " + '-' * 50
          puts "\n<" + sep + ">\n"
          print_item_header(item)
        end

        def print_item_header(item)
          return unless item.respond_to?(:title)
          puts "title: #{item.title.inspect}"
          puts "\n"
        end

        def pad; @_pad ||= ' ' * indent; end

        def stop_run(message='')
          puts "\n"
          puts "Run stopped. " + message
          exit
        end

        def print_help
          help = <<HELP
Run help:
  rake task options:
    * options can be in any order in the argument string
    [help|h]          print help
    [table]           name of table to use
    scope-related:     
      [#,#,...]         record ids for the main run class e.g item, assessment_item
      [limit:#|l:#]     limit records to #
      [offset:#]        offset records starting at #
      [order:col|o:col] order by column; each column value can add a sort order [asc|desc] e.g. order:id:desc,order:title:asc
    column-related:
      [col1,col2,...]   string column name to print
      [rm]              alias for: response_metadata
      [pr]              alias for: processing
      [rmpr]            alias for: [response_metadata, processing]
      [ht]              alias_for: help_tip
      [p]               alias_for: presentation
      [ih]              alias_for: item_header
      [v]               alias_for: value
    print-related:
      [dup]             duplicate item data on 'compare' task (default false)
      [ap]              use awesome_print (default is pp); ignored if awesome_print gem not available
      ap_options:
        [index]                          show array indexes
        [indent:#]                       spaces to indent
        [plain|no_color|no-color]        do not use colors
        [sort_keys|sort-keys|sk]         sort column name and/or nested hash keys
        [no_sort_keys|no-sort-keys|nsk]  do NOT sort column name and/or nested hash keys

  Examples:
    rake thinkspace:weather_forecaster:print_items:all                    #=> print all item columns
    rake thinkspace:weather_forecaster:print_items:all[ap]                #=> use awesome_print gem if available
    rake thinkspace:weather_forecaster:print_items:columns[col1,col2...]  #=> print columns from item records
    rake thinkspace:weather_forecaster:print_items:all[assessment_item]   #=> print all assessment_item columns
    rake thinkspace:weather_forecaster:print_items:compare[col1,col2,...] #=> print item column(s) and associated assessment_items column(s)
    rake thinkspace:weather_forecaster:print_items:columns[p,1]           #=> print item presentation column for item.id 1
    rake thinkspace:weather_forecaster:print_items:compare[p,l:3,o:5,dup] #=> compare presentation columns starting with record 5 for 3 records; duplicate item data
HELP
          puts help
        end



      end

    end
  end
end
