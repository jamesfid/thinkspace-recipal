class Totem::Seed::Loader

  attr_accessor :load_errors, :config_directory, :platform, :seed_directory

  def initialize(engine, options={})
    @load_errors      = []
    @platform         = options[:platform]        || 'thinkspace'  # override in seed.loader(seed_directory: dir-name)
    @seed_directory   = options[:seed_directory]  || 'seed_data'  # override in seed.loader(seed_directory: dir-name)
    @quiet            = options[:quiet]           || false        # override in seed.loader(quiet: true)
    @print            = ::Totem::Core::Console::Print.new
    @config_directory = File.join(engine.root, 'db', seed_directory)
    engine.eager_load!
  end

  # ### Environment variables used.
  def env_config;                    ENV['CONFIG']; end
  def env_auto_input;                ENV['AUTO_INPUT'] || ENV['AI']; end
  def env_reset;                     ENV['RESET']; end
  def env_print_models;              ENV['PRINT_MODELS'] || ENV['PM']; end
  def env_print_config_models;       ENV['PRINT_CONFIG_MODELS'] || ENV['PCM']; end
  def env_debug;                     ENV['DEBUG']; end
  def env_debug_config;              ENV['DEBUG_CONFIG'] || ENV['DC']; end
  def env_test_only;                 ENV['TEST_ONLY'] || ENV['TO']; end

  # ###
  # ### Config Files.
  # ###

  def configs; @_configs ||= ::Totem::Seed::Configs.new(self); end

  def config_names
    cfgs = env_config || ''
    cfgs.split(',').map {|c| c.to_s.strip}
  end

  def config_file(options={})
    file = get_config_directory(options)
    message ">>Loading config file #{file.inspect}."
    hash = YAML.load(File.read(file))
    hash.is_a?(Hash) ? hash.deep_symbolize_keys : Hash.new
  end

  def config_content(options={}); File.read(get_config_directory(options)); end

  def get_config_directory(options={})
    options.symbolize_keys!
    filename = options[:filename]
    raise_error "Config filename is blank in options #{options.inspect}"  if filename.blank?
    file = File.join(config_directory, "#{filename}.yml")
    raise_error "Missing config file: #{file}"  unless File.exists?(file)
    file
  end

  def import_file(options={})
    file = import_file_path(options)
    message ">>Loading import file #{file.inspect}."
    YAML.load(File.read(file)).deep_symbolize_keys
  end

  def import_content(options={}); File.read(import_file_path(options)); end

  def import_file_path(options={})
    options.symbolize_keys!
    filename = options[:filename]
    raise_error "Import name is blank in options #{options.inspect}"  if filename.blank?
    file = File.join(config_directory, "#{filename}.yml")
    raise_error "Missing import file: #{file}"  unless File.exists?(file)
    file
  end

  def erb_file(file)
    YAML.load(ERB.new(File.read(file)).result).deep_symbolize_keys
  end

  # ###
  # ### Seed Models.
  # ###

  def user_class
    klass = resolve_namespace(:user)  # user is a special key as it is a fully qualified model class already
    raise_error "User class [#{class_name}] could not be constantized" if klass.blank?
    klass
  end

  def model_class(*args)
    options    = args.extract_options!
    ns_key     = args.shift
    model      = args.shift || raise_error("Model class cannot be blank [#{args.inspect}]")
    namespace  = resolve_namespace(ns_key)
    model_name = model.to_s.classify
    class_name = "#{namespace}::#{model_name}"
    klass      = class_name.safe_constantize
    raise_error "Class [#{class_name}] could not be constantized" if klass.blank?   # rollback all changes if there are seed errors
    klass
  end

  def new_model(*args)
    options = args.extract_options!
    ns_key  = args.shift
    model   = args.shift
    klass   = model_class(ns_key, model, options)
    model   = klass.new
    options.blank? ? model : populate_model(model, options)
  end

  def populate_model(model, options)
    attrs = model.attribute_names
    model.class.stored_attributes.each {|k,v| attrs += v}
    attrs.each do |a|
      a_sym = a.to_sym
      next if a_sym == :id
      case
      when a.to_s.end_with?('_id')
        if (id = options[a_sym]).present?
          model.send "#{a_sym}=", id
        else
          assoc_sym = a.sub(/_id$/,'').to_sym
          if (assoc = options[assoc_sym]).present?
            model.send "#{a_sym}=", assoc.id
          end
        end
      when a.to_s.end_with?('_type')  # assume polymorphic type
        assoc_sym = a.sub(/_type$/,'').to_sym
        if (assoc = options[assoc_sym]).present?
          model.send "#{a_sym}=", assoc.class.name
        else
          model.send "#{a_sym}=", options[a_sym]  if options.has_key?(a_sym)
        end
      else
        model.send "#{a_sym}=", options[a_sym]  if options.has_key?(a_sym)
      end
    end
    model
  end

  def get_association(*args)
    options          = args.extract_options!
    model            = args.shift
    ns_key           = args.shift
    association      = args.shift
    options[:assign] = false
    assoc_name       = resolve_association_name(model, ns_key, association, options)
    model.send(assoc_name)
  end

  def add_association(*args)
    options          = args.extract_options!
    model            = args.shift
    ns_key           = args.shift
    association      = args.shift
    value            = args.shift
    options[:assign] = true
    name             = resolve_association_name(model, ns_key, association, options)
    model.send(name, value)
  end

  def resolve_namespace(ns_key)
    class_path = ns_key
    class_path = "#{platform}/#{ns_key}" if ns_key.is_a?(Symbol)
    class_path.to_s.classify
  end

  def resolve_association_name(*args)
    options     = args.extract_options!
    model       = args.shift
    ns_key      = args.shift
    association = args.shift
    namespace   = resolve_namespace(ns_key)
    namespace   = namespace.to_s.underscore.gsub('/','_')
    namespace  += '_' + association.to_s.underscore
    association_name = options[:assign] ? "#{namespace}=".to_sym : namespace.to_sym
    raise_error "Model [#{model} does not have association method [#{association_name}]"  unless model.respond_to?(association_name)
    association_name
  end

  # ###
  # ### Reset Tables.
  # ###

  def reset_tables?; env_reset == 'true'; end

  # Reset tables that start with value(s) in 'args' (default is platform name).
  # e.g. @seed.reset_tables; @seed.reset_tables(:thinkspace); @seed.reset_tables(:thinkspace, :totem)
  def reset_tables(*args)
    return unless reset_tables?
    raise_error "Reseting of tables is not supported in a production environment" if ::Rails.env.production?
    args        = [platform] if args.blank?
    table_names = select_reset_tables(args)
    db_name     = active_record_database_name
    raise_error "Reset tables database name is blank. #{active_record_connection_config.inspect}" if db_name.blank?
    message "==Resetting #{table_names.length} #{platform.inspect} tables in database #{db_name.inspect}.", :warn
    [table_names].flatten.compact.sort.each do |table_name|
      delete_all_table_records(table_name)
    end
    reset_common_tables
    run_domain_loader
  end

  def reset_common_tables
    if 'PaperTrail::Version'.safe_constantize.present?
      message "==Resetting 'versions' table.", :warn
      delete_all_table_records(:versions)
    end
    if 'ActsAsTaggableOn::Tag'.safe_constantize.present?
      message "==Resetting 'tags' and 'taggings' table.", :warn
      delete_all_table_records(:tags)
      delete_all_table_records(:taggings)
    end
    if 'Delayed::Job'.safe_constantize.present?
      message "==Resetting 'delayed_jobs' table.", :warn
      delete_all_table_records(:delayed_jobs)
    end
  end

  def run_domain_loader
    message "==Loading domain data."
    Totem::Core::Database::Domain::Loader.new.load_files
  end

  def select_reset_tables(args)
    engine_names = args.blank? ? ::Totem::Settings.registered.engines : args
    active_record_base_connection.tables.select {|tn| select_reset_table?(tn, engine_names)}
  end

  def select_reset_table?(table_name, engine_names)
    engine_names.each do |en|
      return true if table_name.to_s.start_with?(en.to_s)
    end
    false
  end

  def delete_all_table_records(table_name)
    return if table_name.blank?
    active_record_base_connection.execute("TRUNCATE TABLE #{table_name} RESTART IDENTITY") # restart ids at 1
  end

  def active_record_base_connection;   ::ActiveRecord::Base.connection; end
  def active_record_connection_config; ::ActiveRecord::Base.connection_config || {}; end
  def active_record_database_name;     active_record_connection_config[:database]; end

  # ###
  # ### Messages.
  # ###

  def message(msg, level=:info)
    return if (quiet? || ::Rails.env.test?) && level != :error
    return puts '' if msg.blank?
    msg.each_line do |m|
      m    = m.blank? ? '' : m
      line = @print.color "[seed #{level}] #{m}", message_color(level)
      puts(line)
    end
  end

  def message_color(level)
    case level
    when :error  then :red
    when :warn   then :yellow
    else              :cyan
    end
  end

  def quiet?; @quiet == true; end

  def debug?; env_debug == 'true'; end

  def debug_config?; env_debug_config == 'true'; end

  def test_only?; env_test_only == 'true'; end

  # ###
  # ### Errors and Results.
  # ###

  def create_error(object)
    msg = "\n"
    msg += "Model:        [#{object.class.name}]\n"
    msg += "Instance:     [#{object.inspect}]\n"
    msg += "Model Errors: [#{object.errors.full_messages.join(', ')}]\n"
    message msg, :error
    raise_error
  end

  def add_error(msg)
    message msg, :error
    load_errors.push(msg)
  end

  def has_errors?
    load_errors.present?
  end

  def raise_error(message='')
    @print.line message, :red
    raise "Seed exception.  #{message}"
  end

  def seed_results
    if has_errors?
      message "*Errors*. Seed completed with #{load_errors.length} errors.", :error
    else
      message "--Successful. Seed completed with no known errors."
      message "--Check the log or console to make sure there are no mass-assignment warnings."
    end
    message "\n"
  end

  include Totem::Core::Support::Shared

  def error(message='')
    @print.line message, :red
    super
  end

end
