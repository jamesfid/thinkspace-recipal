class Totem::Seed::BaseHelper

  attr_reader :configs, :models, :config, :config_models

  delegate :config_name,      to: :configs
  delegate :config_error,     to: :configs
  delegate :config_warn,      to: :configs
  delegate :config_message,   to: :configs
  delegate :helper_by_key,    to: :configs
  delegate :helper_class_key, to: :configs
  delegate :color,            to: :configs
  delegate :find_all_created, to: :models

  def process?   (cfg=config); config_has_keys?(cfg); end
  def auto_input?(cfg=config); @configs.auto_input? && auto_input(cfg).present?; end

  def initialize(seed, configs)
    @seed             = seed
    @configs          = configs
    @models           = @configs.models
    @max              = @configs.max_config_name
    @process_count    = 0
    @config_models    = Hash.new
    init_base
  end

  def init_base; return; end
  def config_keys; []; end

  # ###
  # ### Process.
  # ###

  def pre_process; @config = {_config_name: "_pre_process_#{self.class.name}"}; end

  def process(config)
    @config = config
    if process?
      process_header
      process_message
    end
  end

  def post_process; @config = {_config_name: "_post_process_#{self.class.name}"}; end

  def process_header
    return if @printed_header
    str = config_keys.map {|k| k.to_s}.join(', ')
    @seed.message color("++#{str} in configs:", :light_green)
    @printed_header = true
  end

  def process_message
    actual_keys = config_keys.select {|k| config.has_key?(k)}.join(', ')
    name        = configs.config_name(config).ljust(@max, '.')
    @seed.message color("  #{(@process_count+=1).to_s.rjust(4)}. #{name}#{actual_keys}", :green)
  end

  # ###
  # ### Helpers.
  # ###

  def config_has_keys?(cfg=config)
    config_keys.each {|key| return true if cfg.has_key?(key)}
    false
  end

  def auto_input(cfg=config)
    auto_input = cfg[:auto_input]
    !auto_input.is_a?(Hash) ? Hash.new : auto_input
  end

  def add_config_model(model, cfg=config); (config_models[cfg] ||= Array.new).push(model); end

  def datetime_value(days, default=0)
    days = default  if days.nil?
    begin; days = days.to_i; rescue; days = default.to_i; end
    DateTime.now + days.days
  end

end
