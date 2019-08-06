class Thinkspace::Seed::WeatherForecaster < Thinkspace::Seed::BaseHelper

  def common_component_titles; [:weather]; end

  def process(*args)
    super
    process_config
    process_auto_input if auto_input?
  end

  private

  def process_config
    @weather_forecaster_config = config[:weather_forecaster]
    return if @weather_forecaster_config.blank?
    process_assessments
    process_forecast_days
  end

  def process_assessments
    @assessments = Array.new
    array = [@weather_forecaster_config[:assessments]].flatten.compact
    return if array.blank?
    phase_components = phase_components_by_config
    phase_components.each do |phase_component|
      phase = @seed.get_association(phase_component, :casespace, :phase)
      hash  = array.find {|h| h[:phase] == phase.title}
      config_error "Weather forecaster assessment for phase #{phase.title.inspect} not found.", config if hash.blank?
      assessment = create_assessment(phase, hash)
      @assessments.push(assessment)
      save_phase_component(phase_component, assessment)
    end
  end

  def create_assessment(phase, hash)
    station_code = hash[:station]
    seed_config_error "Weather forecast station is blank. #{hash.inspect}", config  if station_code.blank?
    station = find_model(:weather_forecaster, :station, location: station_code)
    config_error "Weather forecast station #{station_code.inspect} not found. #{hash.inspect}", config  if station.blank?
    item_names = hash[:items]
    if item_names.present?
      items = Array.new
      [item_names].flatten.compact.each do |name|
        name = 'QUE_' + name.to_s  unless name.to_s.match('QUE')
        item = find_model(:weather_forecaster, :item, name: name)
        config_error "Weather forecast item #{name.inspect} not found. #{hash.inspect}", config  if item.blank?
        items.push item
      end
    else
      config_error "Weather forecast items are blank. #{hash.inspect}", config
    end
    title = hash[:title]
    config_error "Weather forecast assessment title is blank. #{hash.inspect}", config  if title.blank?
    assessment    = create_model(:weather_forecaster, :assessment, title: title, authable: phase, station: station)
    override_keys = [:title, :presentation, :help_tip]
    merge_keys    = [:processing]
    items.each do |item|
      item_attributes = item.attributes.deep_symbolize_keys.except(:id, :created_at, :updated_at)
      override_keys.each do |key|
        item_attributes[key] = hash[key]  if hash.has_key?(key)
      end
      merge_keys.each do |key|
        item_attributes[key] = (item_attributes[key] || Hash.new).deep_merge(hash[key].deep_symbolize_keys)  if hash.has_key?(key)
      end
      create_model(:weather_forecaster, :assessment_item, item_attributes.merge(assessment: assessment, item: item))
    end
    assessment
  end

  def process_forecast_days
    forecast_days = [@weather_forecaster_config[:forecast_days]].flatten.compact
    return if forecast_days.blank?
    forecast_day_class = @seed.model_class(:weather_forecaster, :forecast_day)
    forecast_days.each do |hash|
      days       = hash[:start] || 0
      start_date = Time.now + days.to_i.days
      count      = hash[:count]
      if count.blank?
        now        = Time.now
        count      = now > start_date ? (now.to_date - start_date.to_date) : (start_date.to_date - now.to_date)
        start_date = start_date + 1.days  # include run date as the final date
      end
      count.to_i.times do |i|
        day = forecast_day_class.find_or_create_forecast_day(start_date + i.days)
        @models.add(config, day)
      end
    end
  end

  # ###
  # ### Auto Input.
  # ###

  def process_auto_input
    array = [auto_input[:forecasts]].flatten.compact
    return if array.blank?
    array.each do |options|
      AutoInput.new(@seed, @configs).process(config, @assessments, options)
    end
  end

  class AutoInput < ::Thinkspace::Seed::BaseHelper
    include ::Thinkspace::Seed::AutoInput

    def process(config, assessments, options)
      @config      = config
      @assessments = assessments
      set_options(options)
      setup(options)
      add_forecasts
    end

    def set_options(options)
      super
      @days             = options[:days]
      @completed_days   = options[:completed_days]
      @number_days      = options[:number_days]
      @include_unlocked = options[:include_unlocked] == true
    end

    def setup(options)
      forecast_days  = find_all(:weather_forecaster, :forecast_day).order(:forecast_at)
      @forecast_days = forecast_days.select {|d| d.is_locked?}  unless @include_unlocked
      if @number_days.present?
        index          = number_days.to_i * -1
        @forecast_days = @forecast_days.slice(index, @forecast_days.length)
      end
      if @completed_days.present?
        index                    = @completed_days.to_i * -1
        @forecast_days_completed = @forecast_days.slice(index, forecast_days.length)
      else
        @forecast_days_completed = @forecast_days  # mark all as completed
      end
    end

    def add_forecasts
      @assessments.each do |assessment|
        phase = assessment.authable
        next if skip_phase?(phase)
        items      = @seed.get_association(assessment, :weather_forecaster, :assessment_items)
        ownerables = find_phase_ownerables(phase)
        ownerables.each do |ownerable|
          next if skip_ownerable?(ownerable)

          # Create forecasts for each day for ownerable.
          forecasts = Array.new
          @forecast_days.each do |forecast_day|
            forecast = @seed.get_association(assessment, :weather_forecaster, :forecasts).find_ownerable_day(ownerable, forecast_day.forecast_at)
            if forecast.blank?
              forecast = create_model(:weather_forecaster, :forecast,
                assessment:      assessment,
                ownerable:       ownerable,
                forecast_day_id: forecast_day.id,
                user_id:         ownerable.id,
                state:           @forecast_days_completed.include?(forecast_day) ? 'completed' : forecast_day.state
              )
            end
            forecasts.push(forecast)
          end

          forecasts.each do |forecast|
            items.each do |assessment_item|
              # Create responses for each forecast's assessment item.
              item    = @seed.get_association(assessment_item, :weather_forecaster, :item)
              value   = get_forecast_input_value(item)
              options = {
                forecast:        forecast,
                assessment_item: assessment_item,
                value:           {input: value},
              }
              response = create_model(:weather_forecaster, :response, options)
            end
          end

        end # ownerables
      end # assessments
    end

    def get_forecast_input_value(item)
      # Radio and checkbox values are selected by random.
      temp        = 60
      wspeed      = 10
      metadata    = (item.response_metadata || {}).deep_symbolize_keys
      validations = metadata[:validations] || {}
      choices     = metadata[:choices] || []
      r           = choices.length - 1
      case metadata[:type]
      when 'input'
        if validations[:numericality].present?
          case
          when item.score_var.match(/^TEMP/i)  then (temp += 1).to_s
          when item.score_var.match(/^WSPD/i)  then (wspeed += 1).to_s
          else '1'
          end
        end
      when 'radio'
        index = Random.new.rand(0..r)
        (choices[index] || {})[:id]
      when 'checkbox'
        value = []
        ids   = choices.collect {|c| c[:id]}
        num   = Random.new.rand(1..ids.length)
        num.times do
          index = Random.new.rand(0..r)
          value.push(ids[index])  unless value.include?(ids[index])
        end
        value
      else
        @seed.error "Unknown asssessment item response type #{metadata.inspect}."
      end
    end

  end # AutoInput

end
