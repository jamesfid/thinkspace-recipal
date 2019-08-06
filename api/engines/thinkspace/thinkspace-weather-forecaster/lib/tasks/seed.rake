namespace :thinkspace do
  namespace :weather_forecaster do

    @engine_name        = 'thinkspace_weather_forecaster'
    @item_model_path    = 'thinkspace/weather_forecaster/items'
    @station_model_path = 'thinkspace/weather_forecaster/stations'

    item_namespace = namespace :items do

      task :extract, [] => [:environment] do |t, args|
        @item_domain_yml = Thinkspace::WeatherForecaster::ItemXml::Seed::Items.new.extract_items args.extras
      end

      task :print, [] => [:environment] do |t, args|
        item_namespace['extract'].invoke *args.extras
        puts @item_domain_yml
      end

      task :load, [] => [:environment] do |t, args|
        item_namespace['extract'].invoke *args.extras
        Rake::Task['totem:db:domain:load_from_yml'].invoke @engine_name, @item_model_path, @item_domain_yml
      end

    end

    station_namespace = namespace :stations do

      task :extract, [] => [:environment] do |t, args|
        @station_domain_yml = Thinkspace::WeatherForecaster::ItemXml::Seed::Stations.new.extract_stations args.extras
      end

      task :print, [] => [:environment] do |t, args|
        station_namespace['extract'].invoke *args.extras
        puts @station_domain_yml
      end

      task :load, [] => [:environment] do |t, args|
        station_namespace['extract'].invoke *args.extras
        Rake::Task['totem:db:domain:load_from_yml'].invoke @engine_name, @station_model_path, @station_domain_yml
      end

    end

  end
end
