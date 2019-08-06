module Totem::Test; class Seed
  include Singleton

  @seed_configs_loaded  = Array.new
  @delete_all_performed = false

  def self.load_seeds?; ENV['SEED'] == 'true'; end

  def self.load(options={})
    return unless load_seeds?
    dir          = options[:dir] = (options[:dir] || 'test').to_s
    config       = options[:config]
    configs      = get_seed_configs(config)
    load_configs = Array.new
    configs.each do |cfg|
      name = File.join(dir, cfg).to_s
      next if seed_config_loaded?(name)
      add_seed_config_loaded(name)
      load_configs.push(name)
    end
    return if load_configs.blank?
    @print       = ::Totem::Core::Console::Print.new
    @engine_name = options[:engine_name] || 'thinkspace_seed'
    @seed_class  = options[:seed_class]  || 'Thinkspace::Seed::Seed'
    env_ai       = (options[:auto_input] == true).to_s
    env_pm       = (options[:print_models] == true).to_s
    env_pcm      = (options[:print_config_models] == true).to_s
    env_debug    = (options[:debug] == true).to_s

    ENV['CONFIG'] = load_configs.join(',')
    ENV['AI']     = env_ai
    ENV['PM']     = env_pm
    ENV['PCM']    = env_pcm
    ENV['DEBUG']  = env_debug

    reset_database(options)
    print_env
    get_seed_class.new.process(seed)
  end

  private

  def self.print_env
    color = :light_magenta
    @print.line "  Processing test seed ENV ".ljust(140,'-'), color, :bold
    @print.line "     CONFIG : #{ENV['CONFIG']}", color
    @print.line "     AI     : #{ENV['AI']}", color
    @print.line "     PM     : #{ENV['PM']}", color
    @print.line "     PCM    : #{ENV['PCM']}", color
    @print.line "     DEBUG  : #{ENV['DEBUG']}", color
  end

  def self.seed
    engine = ::Totem::Settings.engine.get_by_name(@engine_name).first
    if engine.blank?
      @print.line "Seed engine #{@engine_name.inspect} not found.  Is it in your Gemfile?\n", :red, :bold
      raise "Seed engine not found."
    end
    ::Totem::Settings.seed.loader(engine)
  end

  def self.get_seed_class
    klass = @seed_class.safe_constantize
    seed.error "Seed class name #{@seed_class} could not be constantized." if klass.blank?
    klass
  end

  def self.add_seed_config_loaded(config); @seed_configs_loaded.push(config); end
  def self.seed_config_loaded?(config);    @seed_configs_loaded.include?(config); end

  def self.get_seed_configs(config)
    seed.error "Seed load config is blank."  if config.blank?
    case
    when config.is_a?(String)  then config.split(',').map {|c| c.strip}
    when config.is_a?(Symbol)  then [config.to_s]
    when config.is_a?(Array)   then config.map {|c| c.to_s.strip}
    else
      seed.error "Seed load config must be a string, symbol or array."
    end
  end

  def self.reset_database(options={})
    return unless options[:delete_all] != false
    return if @delete_all_performed == true
    @delete_all_performed = true
    seed.error "Must be in the 'test' environment to reset tables.  Not #{::Rails.env.inspect}." unless ::Rails.env.test?
    @print.line "  Resetting the database.\n", :light_yellow
    ENV['RESET'] = 'true'
    seed.reset_tables
  end

end; end
