module Totem::Seed::FinderHelpers

  # ### If a instance variable (@find_model_to_model_id=[]) array is defined, and contains an options key, the key
  #     will be converted into 'model_id: model.id'.  An entry for polymorphics is not required.

  # ### Options:
  #    find_or_create:   [true|false]; if true will create the model from the options if not found.
  #    debug:            [true|false]; default false, if true, prints the find sql on the console.
  #                      Debug can be globally turned on by setting '@debug_sql = true'.
  #    create_method:    [string|symbol]; default "#{model_name}_create_options"; call this method to modify the options on a create.
  #                      Alternatively, can override the default method.  Should only be used with 'find_or_create: true'.

  def find_all(ns, model_name); @seed.model_class(ns, model_name).all; end

  # ### find_model(ns, model_name, find_columns, find_options) #=> find_columns and find_options are both optional
  def find_model(ns, model_name, options, *args)
    find_options = args.extract_options!
    find_columns = args.shift
    klass        = @seed.model_class(ns, model_name)
    hash         = model_find_by_hash(klass, options, find_columns, find_options)
    return nil if hash.blank?          # no find values
    find_model_to_model_id(hash)       # change hash keys with models to model-name_id: model.id
    scope = klass.where(hash).limit(1) # using a 'scope' so can do .to_sql when debugging
    debug_find_scope(klass, scope, options)
    begin
      model = scope.first
    rescue ActiveRecord::StatementInvalid => e
      handle_sql_errors(e)
    end
    return model if model.present?
    return nil   unless options[:find_or_create] == true
    model = create_model(ns, model_name, options)
    model
  end

  def model_find_by_hash(klass, options, find_columns, find_options)
    columns = options[:find_or_create] == true ? ([find_columns || :title].flatten.compact) : options.keys
    hash    = options.slice(*columns)
    ids     = options[:id]
    ids     = @models.find_by_ids(klass, config) if ids.blank? && find_options[:domain] != true
    hash[:id] = ids if ids.present?
    hash
  end

  def find_model_to_model_id(options)
    (@find_model_to_model_id || [:user]).each do |name|
      if options.has_key?(name)
        model = options[name]
        options["#{name}_id"] = model.present? ? model.id : nil
        options.delete(name)
      end
    end
  end

  def create_model(ns, model_name, options)
    model_create_options(model_name, options)
    model = @seed.new_model(ns, model_name, options)
    begin
      @seed.create_error(model)  unless model.save
    rescue ActiveRecord::StatementInvalid => e
      handle_sql_errors(e)
    end
    @models.add(config, model)
    model
  end

  def handle_sql_errors(e)
    msg = e.message
    if msg.match(/\.\w+able_id/)
      msg += color("\n\nAre model associations defined (they required in a polymorphic where clause)?", :yellow)
    else
      platform = @seed.platform || ''
      col      = msg.match(/UndefinedColumn.*?\.(\w+)\s/)[1]
      if col.present?
        if col.match('_') && col.match(/^#{platform}/)
          msg += color("\n\nColumn #{col.inspect} appears to be an association. Are model associations defined? e.g. not run with [associations=false]", :yellow)
        else
          msg += color("\n\nIs #{col.to_sym.inspect} included in the '@find_model_to_model_id' array?", :yellow)
        end
      end
    end
    config_error "\n\n#{msg}\n", config
  end

  def model_create_options(model_name, options)
    method = options[:create_method] || "#{model_name}_create_options".to_sym
    self.send(method, options) if self.respond_to?(method)
    options
  end

  def save_model(model)
    @seed.create_error(model)  unless model.save
  end

  def find_file(file, ns=nil)
    config_error "Find file file is blank.", config if file.blank?
    if absolute_path?(file)
      path = ::Rails.root.join(file)
    else
      data_dir = @seed.config_directory
      path     = File.join(data_dir, 'files', file)
    end
    config_error "File #{path.to_s.inspect} is not a file.", config unless File.file?(path)
    path
  end

  def debug_find_scope(klass, scope, options)
    env = @seed.env_debug
    return if env.blank?
    @debug_classes ||= env.split(',')
    if options[:debug] == true || env == 'true' || (env.match('::') && @debug_classes.include?(klass.name))
      find_or_create = options[:find_or_create] == true
      sql_color      = find_or_create ? [:light_magenta, :bold] : [:light_magenta]
      @seed.message color(scope.to_sql, *sql_color)
      @seed.message color("#{klass.name}(#{klass.column_names.join(', ')})", :light_cyan)
      pp options if find_or_create
      puts ''
    end
  end

  # ### sources: [:file|:attachement] default is :file
  def rename_paperclip_file(model, new_filename, source=:file)
    unless paperclip_local_storage?
      config_warn "Paperclip 'rename' requires using the local 'filesystem'.  Not renaming from #{model.file_file_name.inspect} to #{new_filename.inspect}.", config
      return
    end
    path = model.send(source).path
    config_error "Paperclip 'rename' model path is blank #{model.inspect}.", config if path.blank?
    config_error "Paperclip rename file file #{path.inspect} is not a file #{model.inspect}.", config unless File.file?(path)
    file = File.basename(path)
    dir  = File.dirname(path)
    config_error "Paperclip rename file directory #{dir.inspect} is not a directory #{model.inspect}.", config unless File.directory?(dir)
    Dir.chdir dir do
      File.rename(file, new_filename)
    end
    model.send("#{source}_file_name=", new_filename)
    save_model(model)
  end

  def absolute_path?(path); Pathname.new(path).absolute?; end

  def paperclip_local_storage?; defined?(Paperclip) && Paperclip::Attachment.default_options[:storage] == :filesystem; end

end
