require 'rake/testtask'

module Totem; module Test; class Runner

  attr_reader :engine_name, :engine_root, :base_path, :test_patterns

  def process(engine, test_patterns=[])
    @print         = ::Totem::Core::Console::Print.new
    @engine_root   = engine.root
    @engine_name   = engine.engine_name
    @base_path     = File.join(engine_root, 'test')
    @test_patterns = Array.new
    [test_patterns].flatten.compact.each do |dir|
      @test_patterns.push(dir)
    end
    run_tests
  end

  def run_tests
    @test_file_patterns = get_test_file_patterns
    print_run_options
    print_test_patterns
    @test_files = get_test_files(@test_file_patterns)
    if @test_files.blank?
      message "\nNo test files match the test file patterns.\n", :red, :bold
      exit
    end
    engine_test_helper_directory     = File.join(engine_root, 'test').to_s
    totem_test_test_helper_directory = File.expand_path('../../../../../test', __FILE__).to_s
    @test_load_paths                 = [totem_test_test_helper_directory, engine_test_helper_directory].uniq.sort
    print_load_paths
    print_test_files
    print_env
    exit if view_only?
    files     = @test_files.map {|f| File.join(base_path, f)}
    test_name = "test_#{engine_name}".to_sym
    Rails::TestTask.new(test_name) do |t|
      t.libs.push(*@test_load_paths)
      t.test_files = files
      t.verbose = true
    end
    Rake::Task[test_name].invoke  # run the named task defined above
  end

  private

  def view_only?; (ENV['VIEW_ONLY'] || ENV['VO']) == 'true'; end

  def get_test_files(patterns)
    test_files = Array.new
    Dir.chdir(base_path) do
      patterns.each do |pattern|
        test_files += Dir.glob(pattern)
      end
    end
    test_files.uniq.sort
  end

  def get_test_file_patterns
    return ['**/*_test.rb'] if test_patterns.blank?
    patterns = Array.new
    paths    = Array.new
    Dir.chdir(base_path) do
      test_patterns.each do |path|
        file = "#{path}_test.rb" # to test if is a file (e.g. not a directory)
        case
        when path.end_with?('*')
          patterns.push path.sub(/\*$/, '*_test.rb')
        when path.match('\*\*')
          patterns.push path.end_with?('**') ? "#{path}/*_test.rb" : "#{path}*_test.rb"
        when File.directory?(path)
          patterns.push("#{path}/**/*_test.rb")
        when File.file?(file)
          patterns.push(file)
        else
          patterns.push("invalid pattern: #{path.inspect}")
        end
      end
    end
    patterns
  end

  def print_env
    msg  = @print.color("\n  Running in environment ", :light_green)
    msg += @print.color(::Rails.env, :light_cyan, :bold)
    msg += @print.color(" with APP_TOTEM_DATABASE_NAME=", :light_green)
    msg += @print.color(ENV['APP_TOTEM_DATABASE_NAME'] || '', :light_cyan, :bold)
    message(msg)
  end

  def print_run_options
    message("\n")
    rake_cmd = ARGV.join(' ')
    message 'Test Run Options:', :on_cyan, :bold
    message '  run command       :' + " rails #{rake_cmd}", :magenta
  end

  def print_load_paths
    message '  added to load path:', :magenta
    @test_load_paths.each_with_index do |path, index|
      message "   #{(index + 1).to_s.rjust(5)}. #{path}", :magenta
    end
  end

  def print_test_patterns
    patterns = @test_file_patterns
    message '  test file patterns:', :magenta
    patterns.each_with_index do |file, index|
      message "   #{(index + 1).to_s.rjust(5)}. #{file}", :magenta
    end
  end

  def print_test_files
    files = @test_files
    message "  test files (#{files.length}):", :light_green
    max = (files.map {|f| File.basename(f).to_s.length}.max || 0) + 4
    files.each_with_index do |file, index|
      basename = File.basename(file).ljust(max,'.')
      message "   #{(index + 1).to_s.rjust(5)}. #{basename}#{file}", :light_green
    end
  end

  def message(*args); @print.line(*args); end

  def error(message); raise "#{self.class.name}: #{message}"; end

end; end; end
