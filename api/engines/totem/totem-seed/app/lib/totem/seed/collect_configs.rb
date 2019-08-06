class Totem::Seed::CollectConfigs

  attr_reader :caller, :config_content

  delegate :config_name, to: :caller
  delegate :color,       to: :caller

  def initialize(caller, seed, options={})
    @caller  = caller
    @seed    = seed
    @options = options
  end

  def process
    config_names = get_config_names
    return [] if config_names.blank?
    @config_content = process_import_text(config_names)
    debug_config_content if @options[:debug] == true
    configs         = Array.new
    config_names.each do |config_name|
      config                = get_config(config_name)
      config[:_config_name] = config_name
      pre_configs           = load_prereq_files(config)
      pre_configs.each {|c| configs.push(c)  unless configs.include?(c) }
      configs.push(config)  unless configs.include?(config)
    end
    process_imports(configs)
    update_configs_with_prefix(configs)
    configs
  end

  def get_config_names
    config_names = Array.new
    configs      = @seed.config_names
    if configs.blank?
      default_config = @options[:default_config]
      if default_config.present?
        @seed.message color(">>Using default config #{default_config.inspect}", :cyan, :bold)
        configs = default_config
      end
    end
    Array.wrap(configs).each do |name|
      content = @seed.config_content(filename: name)
      if include_configs?(content)
        content = remove_import_text(content)
        config_names.push(name)
        hash  = YAML.load(content).deep_symbolize_keys
        names = hash[:include_configs] or []
        Array.wrap(names).each do |n|
          config_names.push name.match('/') ? File.join(File.dirname(name), n) : n
        end
      else
        config_names.push(name)
      end
    end
    config_names
  end

  # Remove import_text so doesn't create a Psych::SyntaxError.
  def remove_import_text(content)
    regex = Regexp.new /import_text\[.*?\].*?\n/
    return content unless content.match(regex)
    new_content = ''
    content.each_line do |line|
      new_content += line.match(regex) ? '' : line
    end
    new_content
  end

  def include_configs?(content); content.match('include_configs:'); end

  def process_import_text(config_names)
    ::Totem::Seed::ImportText.new(@caller, @seed).process(config_names)
  end

  def process_imports(configs)
    ::Totem::Seed::Import.new(@caller, @seed).process(configs)
  end

  def get_config(config_name)
    if content = config_content[config_name]
      YAML.load(content).deep_symbolize_keys
    else
      @seed.config_file(filename: config_name)
    end
  end

  def add_include_config_names(config, config_names)
    Array.wrap(config[:include_configs] || Array.new).reverse.each do |config_name|
      config_names.unshift(config_name) unless config_names.include?(config_name)
    end
  end

  def load_prereq_files(config, configs=Array.new, times=0, max=15)
    configs.unshift config  unless configs.include?(config)
    prereqs     = [config[:prereq_configs]].flatten.compact
    config_name = config[:_config_name]
    dir         = config_name.match('/') ? File.dirname(config_name) : nil
    if prereqs.present?
      if times >= max
        names = configs.collect {|c| config_name(c)}
        @seed.error "Seed config file prerequisites nested more than #{max} levels deep.  Prereq configs #{names}."
      end
      prereqs.each do |prereq|
        prereq.deep_symbolize_keys! if prereq.is_a?(Hash)
        cname = dir.blank? ? prereq : File.join(dir, prereq)
        prereq = {filename: cname} if value_string_or_symbol?(prereq)
        config_name = prereq[:filename]
        if config_name.present? && config_content[config_name].blank?
          content                     = @seed.config_content(prereq)
          new_content                 = ::Totem::Seed::ImportText.new(@caller, @seed).get_import_content(cname, content)
          config_content[config_name] = new_content if new_content.present?
        end
        config = get_config(config_name)
        config[:_config_name] = prereq[:filename]
        load_prereq_files(config, configs, times+=1, max)
      end
    end
    configs
  end

  def value_string_or_symbol?(value); value.instance_of?(String) || value.instance_of?(Symbol); end

  def update_configs_with_prefix(configs)
    configs.each do |config|
      pre = config[:prefix]
      next if pre.blank?
      update_prefix_keys(config, :spaces, pre,          [:title])
      update_prefix_keys(config, :space_users, pre,     [:spaces])
      update_prefix_keys(config, :assignments, pre,     [:title, :space])
      update_prefix_keys(config, :phases, pre,          [:title, :assignment, :template_name])
      update_prefix_keys(config, :phase_templates, pre, [:title, :name])
      teams = config[:teams]
      if teams.present?
        update_prefix_keys(teams, :team_sets, pre,      [:title, :space])
        update_prefix_keys(teams, :team_set_teams, pre, [:title, :team_set, :space])
        update_prefix_keys(teams, :phase, pre,          [:title, :space, :assignment, :team_sets])
      end
    end
  end

  def update_prefix_keys(config, section, pre, keys)
    array = [config[section]].flatten.compact
    return if array.blank?
    array.each do |hash|
      next unless hash.is_a?(Hash)
      Array.wrap(keys).each do |key|
        next unless hash.has_key?(key)
        value = hash[key]
        next if value.blank?
        case
        when value.is_a?(String)
          hash[key] = "#{pre}#{value}"
        when value.is_a?(Array)
          new_array = Array.new
          value.each do |v|
            v.is_a?(String) ? new_array.push("#{pre}#{v}") : new_array.push(value)
          end
          hash[key] = new_array
        end
      end
    end
  end

  def debug_config_content
    @config_content.each do |key, config|
      @seed.message color("DEBUG Config #{key.inspect} Content (line numbers added by debug):", :light_yellow)
      line_cnt = 0
      config.each_line do |line|
        cnt = (line_cnt += 1).to_s.rjust(4)
        puts "#{cnt}. #{line}"
      end
      puts ''
    end
  end


end
