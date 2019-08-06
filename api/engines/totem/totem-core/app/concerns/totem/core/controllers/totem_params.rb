module Totem
  module Core
    module Controllers
      module TotemParams

        # ######################################################################################
        # @!group Common controller methods to access params keys
     
        # Controller's root key
        def params_root
          key = controller_params_key
          raise "Missing controller params for [#{self.class.name}] key [#{key}]"  unless params.has_key?(key)
          params[key]
        end

        # For associations within the controller's namespace
        def params_association_id(*args)
          options = args.extract_options!
          id      = args.shift
          key     = "#{controller_association_params_key}/#{id}"
          raise "Missing params association in [#{self.class.name}] association key [#{key}]"  unless params_root.has_key?(key)
          options[:delete] ? params_root.delete(key) : params_root[key]
        end

        def controller_params_key
          @_controller_params_key  ||= self.class.totem_controller_model_class.underscore
        end

        def controller_association_params_key
          @_controller_association_params_key ||= self.class.totem_controller_model_class.deconstantize.underscore
        end

      end
    end
  end
end