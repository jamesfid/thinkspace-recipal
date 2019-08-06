def create_weather_forecaster_assessment(*args)
  options    = args.extract_options!
  assessment = @seed.new_model(:weather_forecaster, :assessment, options)
  @seed.create_error(assessment)  unless assessment.save
  assessment
end

def create_weather_forecaster_assessment_item(*args)
  options         = args.extract_options!
  assessment_item = @seed.new_model(:weather_forecaster, :assessment_item, options)
  @seed.create_error(assessment_item)  unless assessment_item.save
  assessment_item
end

def create_weather_forecaster_forecast(*args)
  options  = args.extract_options!
  forecast = @seed.new_model(:weather_forecaster, :forecast, options)
  @seed.create_error(forecast)  unless forecast.save
  forecast
end
