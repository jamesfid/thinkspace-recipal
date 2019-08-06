# This migration comes from thinkspace_weather_forecaster (originally 20150601000000)
class CreateThinkspaceWeatherForecaster < ActiveRecord::Migration
  def change

    create_table :thinkspace_weather_forecaster_stations, force: true do |t|
      t.string      :location
      t.string      :block_number
      t.string      :station_number
      t.string      :place
      t.string      :country
      t.string      :region
      t.string      :state
      t.string      :source
      t.timestamps
      t.index  [:location],  name: :idx_thinkspace_weather_forecaster_stations_on_location
    end

    create_table :thinkspace_weather_forecaster_items, force: true do |t|
      t.string      :name
      t.string      :title
      t.string      :score_var
      t.text        :description
      t.text        :item_header
      t.text        :presentation
      t.json        :response_metadata
      t.json        :processing
      t.json        :help_tip
      t.timestamps
    end

    create_table :thinkspace_weather_forecaster_assessment_items, force: true do |t|
      t.references  :item
      t.references  :assessment
      t.string      :title
      t.text        :description
      t.text        :item_header
      t.text        :presentation
      t.json        :processing
      t.json        :help_tip
      t.timestamps
      t.index  [:item_id],        name: :idx_thinkspace_weather_forecaster_asmt_items_on_item
      t.index  [:assessment_id],  name: :idx_thinkspace_weather_forecaster_asmt_items_on_asmt
    end

    create_table :thinkspace_weather_forecaster_assessments, force: true do |t|
      t.references  :station
      t.references  :authable, polymorphic: true
      t.string      :title
      t.text        :description
      t.timestamps
      t.index  [:authable_id, :authable_type],  name: :idx_thinkspace_weather_forecaster_assessments_on_authable
      t.index  [:station_id],                   name: :idx_thinkspace_weather_forecaster_assessments_on_station
    end

    create_table :thinkspace_weather_forecaster_forecast_days, force: true do |t|
      t.datetime    :forecast_at
      t.string      :state
      t.timestamps
      t.index  [:forecast_at],  name: :idx_thinkspace_weather_forecaster_forecast_days_on_forecast_at
    end

    create_table :thinkspace_weather_forecaster_forecast_day_actuals, force: true do |t|
      t.references  :forecast_day
      t.references  :station
      t.json        :value
      t.text        :original
      t.timestamps
      t.index  [:forecast_day_id],  name: :idx_thinkspace_weather_forecaster_forecast_da_on_day
      t.index  [:station_id],       name: :idx_thinkspace_weather_forecaster_forecast_da_on_station
    end

    create_table :thinkspace_weather_forecaster_forecasts, force: true do |t|
      t.references  :forecast_day
      t.references  :assessment
      t.references  :user
      t.references  :ownerable, polymorphic: true
      t.decimal     :score, precision: 9, scale: 2, default: 0
      t.integer     :attempts, default: 0
      t.string      :state
      t.timestamps
      t.index  [:ownerable_id, :ownerable_type],  name: :idx_thinkspace_weather_forecaster_forecasts_on_ownerable
      t.index  [:forecast_day_id],                name: :idx_thinkspace_weather_forecaster_forecasts_on_day
      t.index  [:assessment_id],                  name: :idx_thinkspace_weather_forecaster_forecasts_on_assessment
    end

    create_table :thinkspace_weather_forecaster_responses, force: true do |t|
      t.references  :forecast
      t.references  :assessment_item
      t.json        :value
      t.timestamps
      t.index  [:forecast_id],        name: :idx_thinkspace_weather_forecaster_responses_on_forecast
      t.index  [:assessment_item_id], name: :idx_thinkspace_weather_forecaster_responses_on_asmt_item
    end

    create_table :thinkspace_weather_forecaster_response_scores, force: true do |t|
      t.references  :response
      t.decimal     :score, precision: 9, scale: 2, default: 0
      t.timestamps
      t.index  [:response_id], name: :idx_thinkspace_weather_forecaster_response_scores_on_response
    end

  end
end
