require 'pp'
class Totem::Seed::Configs

  # PROCESS NOTES:
  #   1. Helpers must extend 'Totem::Seed::BaseHelper' (or one of its descendants) to be included in process.
  #   2. Any helper class name matching '::Base' or '::AutoInput' will not be called in process.
  #   3. Each helper's 'pre_process' method (when defined) is called before calling 'process' (no params).
  #   4. Each helper's 'post_process' method (when defined) is called after calling 'process' (no params).

  attr_reader :models, :print
  attr_reader :configs, :max_config_name
  attr_reader :helpers, :helper_order

  delegate :color, to: :print

  def auto_input?;           @seed.env_auto_input   == 'true'; end
  def print_all_models?;     @seed.env_print_models == 'true'; end
  def print_model_classes?;  @seed.env_print_models.is_a?(String); end
  def print_config_models?;  @seed.env_print_config_models.is_a?(String); end

  def initialize(seed)
    error "Seed loader instance is blank." if seed.blank?
    @seed         = seed
    @print        = ::Totem::Core::Console::Print.new
    @models       = ::Totem::Seed::Models.new(self, @seed)
    @helpers      = Hash.new
    @helper_order = Hash.new
  end

  def setup(options={})
    reset_all_model_column_info(options)
    set_configs(options)
    set_helper_classes_and_order(options)
  end

  def process(options={})
    setup(options) if @helpers.blank?
    call_helper_method_once(:pre_process)
    call_helper_method_with_each_config(:process)
    call_helper_method_once(:post_process)
    print_config_models
  end

  def call_helper_method_with_each_config(method, *args)
    @helper_order.each do |key|
      @configs.each do |config|
        call_helper_method_by_key(key, method, config, *args)
      end
    end
  end

  def call_helper_method_once(method, *args)
    @helper_order.each do |key|
      call_helper_method_by_key(key, method, *args)
    end
  end

  def call_helper_method_by_key(key, method, *args)
    helper = helper_by_key(key)
    helper.send(method, *args) if helper.respond_to?(method)
  end

  def helper_by_key(key)
    helper = @helpers[key]
    @seed.error "Seed helper instance #{key} not found." if helper.blank?
    helper
  end

  def helper_by_model(model); helper_by_key(helper_class_key(model).pluralize); end # class or model

  def helper_class_key(klass); model_class_name(klass).demodulize.underscore.to_sym; end

  def model_class_name(model); model.is_a?(Class) ? model.name : model.class.name; end

  def config_name(config); config[:_config_name]; end

  def config_warn(message, config=nil); config_message(color("[WARNING] #{message}", :light_yellow), config); end

  def config_message(message, config=nil)
    message += " (#{config_name(config)})"  if config.present?
    @seed.message message
  end

  def config_error(message, config=nil)
    message = "[#{config_name(config)}] " + message  if config.present?
    @seed.error color(message, :red, :bold)
  end

  private

  def reset_all_model_column_info(options)
    platform      = options[:platform] || @seed.platform
    name          = platform.camelize
    model_classes = ActiveRecord::Base.descendants
    model_classes.each do |klass|
      next unless klass.name.match(name)
      klass.reset_column_information
    end
  end

  # ###
  # ### Collect Configs and set Helper Classes.
  # ###

  def set_configs(options)
    @configs = ::Totem::Seed::CollectConfigs.new(self, @seed, options).process
    if @configs.blank?
      @seed.message("No seed configs found.  Did you use the CONFIG='config-name' enviroment variable?", :error)
      exit
    end
    names    = @configs.map{|config| config_name(config)}
    print_array(names, '>>Processing seed configs in this order:', :cyan)
    @max_config_name = (names.map {|n| n.to_s.length}.max || 0) + 2
    if @seed.debug_config?
      @seed.message ''.ljust(80, '-'), :warn
      @seed.message "Debug configs:", :warn
      pp @configs
      exit
    end
    @configs
  end

  def set_helper_classes_and_order(options)
    order          = options[:order] || []
    helper_classes = get_app_helper_classes(options[:namespaces])
    ordered        = Array.new
    others_keys    = Array.new
    others         = Array.new
    helper_classes.each do |helper|
      key = helper_class_key(helper)
      next if helper.name.match('::Base')      # ignore any base helpers others extend
      next if helper.name.match('::AutoInput') # ignore any auto input classes
      inst  = @helpers[key] = helper.new(@seed, self)
      index = order.index(key)
      case
      when index.present?             then ordered[index] = key
      when inst.config_keys.present?  then others_keys.push(key)
      else                                 others.push(key)
      end
    end
    @helper_order = (ordered + others_keys + others).compact
    max           = (@helpers.keys.map {|k| k.to_s.length}.max || 0) + 2
    array         = @helper_order.map {|k| "#{k.to_s.ljust(max,'.')}#{@helpers[k].class.name}"}
    print_array(array, '>>Processing seed helpers in this order (key...class.name):', :cyan)
  end

  def get_app_helper_classes(ns)
    Totem::Seed::BaseHelper.descendants
  end

  # ###
  # ### Print Models.
  # ###

  def print_config_models
    if print_all_models?
      print_all_config_models
      return
    end
    print_models_by_class    if print_model_classes?
    print_models_for_configs if print_config_models?
  end

  def print_all_config_models
    @configs.each do |config|
      next if config[:print_models] == false
      @models.print_config_models(config)
    end
  end

  def print_models_by_class
    names       = @models.get_all_class_names
    env_classes = [@seed.env_print_models.split(',')].flatten.compact.sort
    env_classes.each do |c|
      match   = c.to_s.downcase
      classes = names.select {|n| n.to_s.downcase.match(/#{match}/)}.sort
      config_warn "Print model class #{c.inspect} did not match any created models.  Skipped." if classes.blank?
      classes.each do |class_name|
        klass = class_name.safe_constantize
        if klass.blank?
          config_warn "Print model class #{class_name.inspect} cannot be constantized.  Skipped."
          next
        end
        @models.print_all_models_for_class(klass)
      end
    end
  end

  def print_models_for_configs
    env_names = [@seed.env_print_config_models.split(',')].flatten.compact.sort
    @configs.each do |config|
      name  = config_name(config).downcase
      match = env_names.find {|n| name.match(n.to_s.downcase)}
      next if match.blank?
      @models.print_config_models(config)
    end
  end

  def print_array(array, title=nil, c=nil)
    @seed.message color(title, c, :bold) if title.present?
    array.each_with_index do |val, i|
      name = val.is_a?(Class) ? val.name : val
      @seed.message color "  #{(i+1).to_s.rjust(4)}. #{name}", c
    end
  end

end
