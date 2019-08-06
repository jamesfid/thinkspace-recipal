module Totem
  module Core
    module Serializers
      module ActiveModelSerializer

        extend ActiveSupport::Concern
        
        module ClassMethods

          def totem_root_path
            @_totem_root_path ||= self._root
          end

          def totem_root_name
            @_totem_root_name ||= self._root.gsub(/\//, '_')
          end

          def totem_associations
            self._associations || {}
          end

          def totem_serialize_as_json(items, options={})
            items = totem_serialize_set_root_options(items, options)
            items.active_model_serializer.new(items, options).as_json
          end

          def totem_serialize_set_root_options(items, options)
            if items.respond_to?(:to_ary)
              root_ids = items.map(&:id)
              root     = totem_root_path.pluralize
            else
              root_ids = [items.id]
              if options[:plural_root].blank?
                root = totem_root_path
              else
                root  = totem_root_path.pluralize
                items = [items]
              end
            end
            options[:root]     = root  unless options[:root] == false
            options[:root_ids] = root_ids  # set the root record ids incase a model association references itself
            items
          end

        end

        # Override ASM method.
        # CAUTION: The 'include!' 'include:' option sets whether to include the associated records
        # in the json payload (e.g. 'not' whether to include the association's key and ids themselves).
        # 'include: true' basicially means side-load the records.
        # To remove an association key (and ids) from the record's json, 'remove' the association.
        def include_associations!
          associations = self.class.totem_associations.keys
          return if associations.blank?
          associations.each do |association_name|
            next if serializer_options.remove_association?(self, association_name)
            next if serializer_options.skip_collect_association?(association_name)
            include! association_name, include: serializer_options.include_association?(self, association_name)
          end
        end

        # Override ASM method to add abilities to json.
        def attributes
          serializer_options.set_root_serializer(self)
          abilities = serializer_options.skip_collect_ability? ? nil : get_totem_abilities
          serializer_options.collect_record_data(self, abilities)
          return Hash.new if serializer_options.collect_only?
          update_totem_attributes_hash(super)
        end

        def update_totem_attributes_hash(hash)
          only   = serializer_options.get_only_attributes(self)
          add    = serializer_options.get_add_attributes(self)
          except = serializer_options.get_except_attributes(self)
          if only.present?
            (hash.keys - only).each {|a| hash.delete(a)}  # delete all keys but the 'only' attributes
          end
          if add.present?
            add.each {|a| hash[a] = object.send(a)  if object.respond_to?(a) && !hash.has_key?(a)}
          end
          if except.present?
            except.each {|a| hash.delete(a)}
          end
          hash
        end

        # Called by ASM 'attributes' method override above.
        # This 'get' method calls the 'totem_abilities' method that should be
        # overridden by the authorization system.
        # If an 'include_ability' is set for the association, this will is set first then the authorization
        # system abilities added (this may override the include_ability value if the same action is used).
        def get_totem_abilities
          actions         = serializer_options.get_ability_actions(self)
          include_ability = serializer_options.get_include_ability(self)
          return nil if actions.blank? && include_ability.blank?
          abilities = Hash.new
          if include_ability.present?
            raise "Include abilities is not a hash [#{include_ability.inspect}]"  unless include_ability.kind_of?(Hash)
            abilities = abilities.merge(include_ability.symbolize_keys)
          end
          (actions || []).each do |action|
            abilities[action] = totem_ability(object, action)
          end
          abilities_debug_log(actions, abilities)  if serializer_options.debug_abilities?
          abilities
        end

        # During serializer creation/initialization, a method is generated for
        # each serializer's association that calls the totem 'get' has_one/has_many
        # below.  The 'get' methods call the 'non-get' methods that should be
        # overridden by the authorization system.
        def get_totem_authorize_has_one(association_name, do_authorize)
          if serializer_options.blank_association?(self, association_name)
            authorize_blank_debug_log(association_name, do_authorize, :has_one)  if serializer_options.debug_authorize_blank?
            return nil
          end
          action = serializer_options.get_authorize_action(self, association_name)
          authorize_debug_log(association_name, do_authorize, action, :has_one) if serializer_options.debug_authorize?
          if action.blank? || do_authorize == false
            object.send(association_name)
          else
            totem_authorize_has_one(object, association_name, action)
          end
        end

        def get_totem_authorize_has_many(association_name, do_authorize)
          if serializer_options.blank_association?(self, association_name)
            authorize_blank_debug_log(association_name, do_authorize, :has_many)  if serializer_options.debug_authorize_blank?
            return []
          end
          action            = serializer_options.get_authorize_action(self, association_name)
          association_scope = serializer_options.get_association_scope(self, association_name)
          authorize_debug_log(association_name, do_authorize, action, :has_many, association_scope) if serializer_options.debug_authorize?
          if action.blank? || do_authorize == false
            scope = object.send(association_name)
            add_association_scope(scope, association_scope).to_a
          else
            scope = totem_authorize_has_many(object, association_name, action)
            add_association_scope(scope, association_scope).to_a
          end
        end

        # Apply any additional scopes to the current association's scope (e.g. where, order, etc.).
        def add_association_scope(scope, association_scope)
          if association_scope.present?
            association_scope.each do |key, values|
              values.each do |value|
                raise "Invalid scope method #{key.inspect} with value #{value.inspect}"  unless scope.respond_to?(key)
                value = replace_value_keys(value)
                case 
                when value.nil?
                  scope = scope.send(key)
                when value.kind_of?(Array)
                  # If an array, the array elements will be sent as parameters.
                  # To pass a single array as a parameter, put it in a hash instead.
                  scope = scope.send(key, *value)
                else
                  scope = scope.send(key, value)
                end
              end
            end
          end
          scope
        end

        def replace_value_keys(value)
          case 
          when value.kind_of?(Hash)
            value.each do |k,v|
              value[k] = replace_value_key(v)
            end
            value
          when value.kind_of?(Array)
            value.collect {|v| replace_value_key(v)}
          else
            replace_value_key(value)
          end
        end

        # Replace common 'key' symbols with the actual object (otherwise return the original value).
        def replace_value_key(value)
          case value
          when :object, :record
            object
          when :current_user
            current_user
          when :current_ability
            current_ability
          else
            value
          end
        end

        # Method that should be overridden by an ability module.
        def totem_ability(record, action)
          raise "Totem abilities not implemented."
        end

        # Methods that should be overridden by an authorize module.
        def totem_authorize_has_many(record, association_name, action)
          raise "Totem authorize :has_many not implemented."
        end

        def totem_authorize_has_one(record, association_name, action)
          raise "Totem authorize :has_one not implemented."
        end

        # Debug log messages.
        def abilities_debug_log(actions, abilities)
          serializer_options.debug_log "\n"
          serializer_options.debug_log "serializer       #{self.class.name.inspect}"
          serializer_options.debug_log "model            #{object.class.name.inspect} [id: #{object.id.inspect}]"
          serializer_options.debug_log "abilities        #{abilities.inspect}"
        end

        def authorize_debug_log(association_name, do_authorize, action, type, scope=nil)
          id       = "#{object.id.inspect}".rjust(5,'0')
          message  = "#{object.class.name.inspect.ljust(62)}  [#{id}]"
          message += action.present? ? "  #{action.inspect.ljust(12)}" : "  no-auth".ljust(12)
          message += "  #{association_name.inspect.ljust(62)}"
          if scope.present?
            scopes = []
            scope.each {|key,value| scopes.push("#{key}=>#{value.inspect}")}
            message += "  #{scopes.join(', ')}"
          end
          puts "[serializer debug] #{message}"  if serializer_options.debug_run?
          serializer_options.debug_log message
        end

        def authorize_blank_debug_log(association_name, do_authorize, type)
          serializer_options.debug_log "Blanking #{type.inspect} association #{association_name.inspect}"
        end

      end
    end
  end
end
