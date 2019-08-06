module Totem::Test; module Routes; class Config

  attr_reader :controller_class
  attr_reader :routes_config
  attr_reader :config
  attr_reader :engine_routes

  def initialize(klass, config, routes_config)
    @controller_class = klass
    @config           = config.is_a?(Hash) ? config : Hash.new
    @routes_config    = routes_config
    @engine_routes    = config[:engine_routes]  # used in describe before for to set the @routes
  end

  def unauthorized_user_types; [:unauthorized_readers, :unauthorized_updaters, :unauthorized_owners]; end

  def short_name; controller_class.name.demodulize; end

  def route_class; ::Totem::Test::Routes::Route; end
  def new_route(options); route_class.new(options); end

  def controller_routes; config[:controller_routes].map {|r| new_route(r)}; end

  def controller_match?(*args)
    matches = [args].flatten.compact.map {|m| m.to_s.downcase}
    name    = controller_class.name.underscore
    matches.each {|m| return true if name.match(m)}
    false
  end

  def readers;                routes_config.options[:readers];  end
  def updaters;               routes_config.options[:updaters]; end
  def owners;                 routes_config.options[:owners];   end
  def unauthorized_readers;   routes_config.options[:unauthorized_readers];  end
  def unauthorized_updaters;  routes_config.options[:unauthorized_updaters]; end
  def unauthorized_owners;    routes_config.options[:unauthorized_owners];   end

  def controller_action_route(action)
    return [] if action.blank?
    options = config[:controller_routes].find {|r| r[:action] == action.to_sym}
    raise "No route found for controller #{controller_class.name.inspect} and action #{action.inspect}."  if options.blank?
    new_route(options)
  end

  def get_engine_by_name(name)
    error "Engine root name is blank." if name.blank?
    ::Totem::Settings::engine.get_by_name(name.to_s).first
  end

  def error(message=''); raise "#{self.class.name}: #{message}"; end

end; end; end
