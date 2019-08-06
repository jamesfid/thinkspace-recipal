module Totem::Test::Routes
extend ActiveSupport::Concern

  module GetRouteConfigs

    def get_controller_route_config(options={}); get_controller_route_configs(options).first; end

    def get_controller_route_configs(options={})
      routes_config = get_route_config_options(options)
      config_class  = route_config_class
      get_controller_classes_and_actions(routes_config).map {|klass, config| config_class.new(klass, config, routes_config)}
    end

    def get_controller_classes_and_actions(options={})
      config  = get_route_config_options(options)
      engines = ::Totem::Settings.engines.select {|e| config.engine_match?(e.engine_name)}
      hash    = Hash.new
      engines.each do |engine|
        engine.routes.routes.each do |route|
          defaults = route.instance_variable_get(:@defaults)
          next if defaults.blank?
          controller_path = (defaults[:controller] || '') + '_controller'
          action          = (defaults[:action] || '').to_sym
          next unless config.action_match?(action)
          next unless config.controller_match?(engine.engine_name, controller_path, action)
          controller_class = controller_path.camelize.safe_constantize
          next if controller_class.blank?
          class_hash   = (hash[controller_class] ||= Hash.new)
          class_routes = (class_hash[:controller_routes] ||= Array.new)
          class_hash[:engine_routes] ||= engine.routes
          required_parts       = route.required_parts || []
          type                 = required_parts.include?(:id) ? :member : :collection

          # request_method_match = (route.instance_variable_get(:@request_method_match)|| []).first  # Rails 5
          # verb                 = request_method_match.blank? ? '' : request_method_match.verb      # Rails 5
          request_method_match = route.instance_variable_get(:@constraints)
          verb                 = request_method_match.blank? ? '' : request_method_match[:request_method]
          verb                 = verb.inspect.gsub(/[\/^$]/, '')

          helper               = route.instance_variable_get(:@name)
          test_it_name         = "..<##{action}>..#{verb.downcase}..#{type}"
          class_routes.push(
            action:          action,
            verb:            verb,
            type:            type,
            helper:          helper,
            controller_path: controller_path,
            test_it_name:    test_it_name,
            options:         config.options,
          )
        end
      end
      hash
    end

    def get_route_config_options(options); options.is_a?(route_config_options_class) ? options : new_route_config_options(options); end

    # ###
    # ### Overrides.
    # ###

    # Override this method to auto-supply platform defaults.
    def new_route_config_options(options={}); route_config_options_class.new(options); end

    # Override these methods to return a different class than the default.
    def route_config_class;         ::Totem::Test::Routes::Config; end
    def route_models_class;         ::Totem::Test::Routes::Models; end
    def route_config_options_class; ::Totem::Test::Routes::RoutesConfigOptions; end

  end

  class_methods do
    include GetRouteConfigs
  end

  included do
    include GetRouteConfigs

    # Process of controller helper methods called:
    #   * route.setup  # note: options are not created yet
    #   - test calls 'send_route_request'
    #   - build base request options with default params (including auth: params)
    #   - build request model dictionary
    #   * route.before_save
    #   - save request model dictionary
    #   - set route.model
    #   * route.params
    #   * route.after_save

    def send_route_request(options={})
      if @route.sign_in?
        send_sign_in_route_request(options)
        return
      end
      set_route_request_options(options)
      hash = @route.member? ? send_member_route_request(options) : send_collection_route_request(options)
      print_response_json(hash)  if print_json?
      hash
    end

    def get_let_models; get_let_value_array(:models); end

    def find_model_in_let_models(model_class); model_class && get_let_models.find {|m| m.is_a?(model_class)}; end

    private

    def set_route_request_options(options={})
      params           = get_let_value(:params)
      options[:params] = params.present? ? params.with_indifferent_access : new_params_hash
      options[:params].merge!(user_id: user.id)  if @route.validate?
      options[:action] ||= @route.action
      options[:verb]   ||= @route.verb
      options[:auth]     = let_auth_params(options)
      options
    end

    def send_sign_in_route_request(options)
      sign_in_user = get_let_value(:user)
      raise "User is blank.  Cannot sign-in user."  if sign_in_user.blank?
      sign_in_params = {identification: sign_in_user.email, password: :password}
      process_request(@route.action, @route.verb, sign_in_params)
    end

    def send_member_route_request(options)
      set_route_request_model(options)
      raise "Member route model is blank #{@route.test_it_name.inspect}."  unless @route.model.present?
      add_action_attributes_to_options(options)
      common_route_request(options)
      controller_member(user, options)
    end

    def send_collection_route_request(options)
      set_route_request_model(options)
      add_action_attributes_to_options(options)
      common_route_request(options)
      controller_collection(user, options)
    end

    def common_route_request(options)
      @route.params(options)  # allow controller specific changes to the options
      options[:print_params] = print_params?
      @route.after_save(options) # allow controller specfic changes to the database
    end

    def add_action_attributes_to_options(options)
      model = @route.model
      return if model.blank?
      add_params   = Hash.new
      options[:id] = model.id  if @route.member? && !options.has_key?(:id)
      case
      when @route.create? || @route.update? || @route.include_model_in_params?
        data        = Hash.new
        data[:id]   = model.id
        data[:type] = model.class.name.underscore
        data[:attributes] = model.attributes.except(:id)
        add_params[:data] = data
      when @route.select?
        add_params[:ids] = [model.id]
      end
      options[:params].reverse_merge!(add_params)
    end

    def set_route_request_model(options)
      model_name  = get_controller_model_class_name
      model_class = model_name.safe_constantize
      if model_class.blank? || !is_active_record?(model_class)
        dictionary = Hash.new
        get_let_models.each {|m| dictionary[m.class] = m}  # just set the dictionary to the base models (returns so records are not saved)
        @route.before_save(dictionary, options)
        return
      end
      model = find_model_in_let_models(model_class)
      if model.present?
        @route.set_model(model)
      else
        route_models_class.new(self, @route).new_route_dictionary(model_class, options)
        print_route_dictionary(@route.dictionary)      if print_dictionary?
        print_route_dictionary_ids(@route.dictionary)  if print_dictionary_ids?
      end
    end

    def let_auth_params(options={})
      auth              = Hash.new
      auth[:authable]   = get_let_value(:authable)
      auth[:ownerable]  = get_let_value(:ownerable)
      auth[:sub_action] = get_let_value(:sub_action)
      if @route.view_action?
        auth[:view]     = get_let_value(:view) || get_let_value(:user)
        auth[:view_ids] = get_let_value(:view_ids)
      end
      (options[:auth] || Hash.new).reverse_merge(auth)
    end

    def print_params?;          get_let_value(:print_params).present?         || @route.print_params?; end
    def print_json?;            get_let_value(:print_json).present?           || @route.print_json?; end
    def print_dictionary?;      get_let_value(:print_dictionary).present?     || @route.print_dictionary?;  end
    def print_dictionary_ids?;  get_let_value(:print_dictionary_ids).present? || @route.print_dictionary_ids?; end

    def print_response_json(hash)
      puts "\n"
      puts "---response json: #{@NAME.inspect} --------------"
      pp hash
    end

  end # included

end
