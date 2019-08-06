namespace :thinkspace do
  namespace :weather_forecaster do
    print_table = namespace :print_table do

      task :all do |t, args|
        print_table['call_print_table_method'].invoke(:all, args.extras)
      end

      task :columns do |t, args|
        print_table['call_print_table_method'].invoke(:columns, args.extras)
      end

      task :compare do |t, args|
        print_table['call_print_table_method'].invoke(:compare, args.extras)
      end

      task :call_print_table_method, [:call_method] => [:environment] do |t, args|
        print_table['print_table_class'].invoke
        @print_table_class.new.send args.call_method, args.extras
      end

      task :print_table_class do |t, args|
        @print_table_class ||= Thinkspace::WeatherForecaster::Utility::PrintTable
      end

    end
  end
end
