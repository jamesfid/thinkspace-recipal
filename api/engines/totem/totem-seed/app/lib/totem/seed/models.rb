# Allow model titles (e.g. assignments and phases) to be identical in different configs.
# Collects the model ids created by a config which can be used to add the ids to the 'find_by' options e.g. id: [1,2,3].
# To remove adding the ids in all subsequent find_bys (unless the config is passed in), call 'clear_find_by'.

class Totem::Seed::Models

  attr_reader :config_model_ids
  attr_reader :configs, :find_config_name

  delegate :config_name,        to: :configs
  delegate :model_class_name,   to: :configs
  delegate :color,              to: :configs

  def initialize(configs, seed)
    @configs          = configs
    @seed             = seed
    @config_model_ids = new_hash
    @sep_len          = 100
    clear_find_by
  end

  def add(config, model)
    config_model_ids_array(config_name(config), model).push(model.id)
    set_find_by(config)
  end

  def find_by_ids(klass, name=find_config_name)
    return nil if name.blank?
    name = config_name(name) if name.is_a?(Hash) # get the config's name if the config hash is passed
    config_model_ids_array(name, klass)
  end

  def clear_find_by; @find_config_name = nil; end

  def set_find_by(config); @find_config_name = config_name(config); end

  def find_all_created(klass)
    ids = find_all_model_ids_by_class(klass)
    return nil if ids.blank?
    klass.where(id: ids)
  end

  def find_all_model_ids_by_class(klass)
    mname = model_class_name(klass)
    ids   = Array.new
    config_model_ids.each do |cfg_name, hash|
      ids += (hash[mname] || [])
    end
    ids
  end

  def get_all_class_names; [config_model_ids.values.map {|hash| hash.keys}].flatten.compact; end

  def print; pp config_model_ids; end

  def print_config_models(name=find_config_name); _print_config_models(name); end

  def print_models; _print_models; end

  def print_model(model, indent=nil); _print_models_for_class(model.class, [model.id], indent); end

  def print_all_models_for_class(klass); _print_all_models_for_class(klass); end

  private

  def new_hash; HashWithIndifferentAccess.new; end

  def config_model_ids_array(name, model)
    hash = (config_model_ids[name] ||= new_hash)
    (hash[model_class_name(model)] ||= Array.new)
  end

  def include_model?(model, options)
    return false unless config_model_ids_array(find_config_name, model).include?(model.id)
    only   = [options[:only]].flatten.compact
    except = [options[:except]].flatten.compact
    title  = model.title
    case
    when title.blank?
      false
    when only.present?
      only.include?(title)
    when except.present?
      !except.include?(title)
    else
      true
    end
  end

  def print_config_header(name)
    hdr = color("Models for config (#{name})".ljust(@sep_len, '-'), :yellow, :bold)
    puts "\n", color(hdr, :on_blue)
  end

  def _print_all_models_for_class(klass)
    return if klass.blank?
    ids = find_all_model_ids_by_class(klass)
    hdr = color("Models for (#{klass.name}) ids: #{ids}".ljust(@sep_len, '-'), :yellow, :bold)
    puts "\n\n", color(hdr, :on_blue), "\n"
    _print_models_for_class(klass, ids)
  end

  def _print_models
    config_model_ids.keys.sort.each do |name|
      _print_config_models(name)
    end
  end

  def _print_config_models(name)
    name = config_name(name) if name.is_a?(Hash) # pass the config name or config hash
    return if name.blank?
    hash = config_model_ids[name] || {}
    return if hash.blank?
    print_config_header(name)
    keys = hash.keys.sort
    keys.each do |key|
      ids = hash[key]
      next if ids.blank?
      klass = key.safe_constantize
      next if klass.blank?
      puts "\n\n", color("  #{klass.name} ids: #{ids}".ljust(@sep_len, '-'), :yellow)
      _print_models_for_class(klass, ids)
    end
    puts "\n\n"
    end

  def _print_models_for_class(klass, ids, indent=nil)
    indent ||= ' ' * 6
    ids.each do |id|
      record = klass.find_by(id: id)
      if record.blank?
        puts color("#{key.inspect} record id [#{id}] not found.", :red, :bold)
      else
        lines = ''
        PP.pp(record, lines)
        lines.each_line do |line|
          line.strip!
          case
          when line.match(/^#</)            then line = color(line.chomp, :cyan, :bold)
          when line.match(/^id:/)           then line = color(line.chomp, :green, :bold)
          when line.match(/^title:/)        then line = color(line.chomp, :light_green)
          when line.match(/^first_name:/)   then line = color(line.chomp, :light_green)
          end
          puts indent + line
        end
      end
      puts ''
    end
  end

end
