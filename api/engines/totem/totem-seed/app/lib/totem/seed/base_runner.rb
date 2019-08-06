class Totem::Seed::BaseRunner

  attr_reader :print, :options

  delegate :color, to: :print

  def initialize(args)
    @print       = ::Totem::Core::Console::Print.new
    @options     = HashWithIndifferentAccess.new
    parse_args(args)
    print_run_header
    print_help if options?(:h, :help) && self.respond_to?(:run_help)
  end

  def print_help
    puts color('  Arguments help:', :light_green)
    hash = run_help
    exit unless hash.is_a?(Hash)
    max = (hash.keys.map {|k| k.to_s.length}.max || 0) + 4
    hash.each do |key, value|
      k = color(key.to_s.ljust(max,'.'), :light_green)
      puts "     #{k}#{value}"
    end
    puts "\n"
    exit
  end

  def print_run_header(message='')
    puts "\n\n"
    message += ' ' if message.present?
    message  = "#{message}#{self.class.name.demodulize} -- [#{self.class.name}] "
    puts color(message.ljust(140,'-'), :cyan, :bold)
    puts ''
  end

  def print_run_done
    puts ''
    puts color('Run done.', :green, :bold)
    puts ''
    exit
  end

  def print_file(content); puts content; end

  # ###
  # ### Helpers.
  # ###

  def ordered_hash;    ::ActiveSupport::OrderedHash.new; end
  def ordered_options; ::ActiveSupport::OrderedOptions.new; end

  def create_file?; options?(:f, :file); end
  def print_file?;  options?(:p, :print); end

  # ### If options has one of the keys in args, returns the keys value unless the value is nil,
  # ### then assumes was a 'key-only' (e.g. p) and retruns true that it exists.
  def options?(*args)
    val = false
    options.each do |key, value|
      next unless args.include?(key.to_sym)
      val = options[key].nil? ? true : options[key]
      break
    end
    val
  end

  def parse_args(args)
    extras = args.extras || Array.new
    extras.each do |arg|
      k,v = arg.split('=',2)
      next if k.blank?
      k.strip!
      v.strip! if v.is_a?(String)
      options[k] = v
    end
  end

  def validate_number(key=:n)
    val = options[key]
    return nil if val.blank?
    stop_run "Options number (#{key}=#) is not a number but #{val.inspect}." unless numeric?(val)
    val.to_i
  end

  def numeric?(string)
    !!Kernel.Float(string) # `!!` converts parsed number to `true`
    rescue TypeError, ArgumentError
      false
  end

  def validate_yaml(content, options={})
    str = get_output_string(content)
    begin
      hash = YAML.load(str)
    rescue Psych::Exception => e
      return e if options[:return_error] == true
      stop_run "[ERROR] Output is invalid YAML.  Error: #{e}"
    end
    hash
  end

  def stop_run(message)
    puts ''
    puts color(message, :red, :bold)
    puts ''
    exit
  end

  # ###
  # ### File Actions.
  # ###

  def output_yaml(content)
    variables = content[:variables]
    yaml      = content.except(:variables).deep_stringify_keys.to_yaml
    yaml.sub!(/^---/, '')
    if variables.present?
      vars = variables.map {|v| "- #{v}"}.join("\n") + "\n"
      output_content("variables:\n" + vars + yaml)
    else
      output_content(yaml)
    end
  end

  def output_content(content)
    str = get_output_string(content)
    print_file(str)  if print_file?
    create_file(str) if create_file?
    validate_yaml(content)
    print_run_done
  end

  def get_output_string(content)
    content.is_a?(Array) ? content.join("\n") : content.dup
  end

  def read_file(file); File.file?(file) ? File.read(file) : stop_run("Is not a file #{file.inspect}"); end

  def create_file(content)
    file = get_create_filename
    dir  = File.dirname(file)
    stop_run "Output content directory is not a directory #{dir.inspect}" unless File.directory?(dir)
    stop_run "Output content file is a directory #{file.inspect}" if File.directory?(file)
    File.open(file, 'w') {|f| f.write(content)}
    puts color("\nCreated file #{file.inspect}.", :light_green)
  end

  def get_create_filename
    ext      = options?(:ext) || 'yml'
    filename = self.class.name.underscore.gsub('/','_') + ".#{ext}"
    ::Rails.root.join('db', filename)
  end

end
