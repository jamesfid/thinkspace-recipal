module Thinkspace
  module Html
    module Api
      class ContentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options

        def show
          controller_render(@content)
        end

        def view
          controller_render_view(@content, delete: :elements)
        end

        def select
          controller_render(@contents)
        end

        def update
          begin
            @content.transaction do
              html = params_root[:html_content]
              hash = validate_html_content(html)
              process_element_changes(hash[:create], hash[:delete])
              @content.html_content = html
              controller_save_record(@content)
            end
          rescue ProcessInputElementError
            controller_render_error(@content)
          end
        end

        def validate
          html = params[:new_html]
          controller_render_json validate_html_content(html)
        end

        private

        # ###################################
        # ### Process Content Element Changes
        # ###################################

        def process_element_changes(elements_create, elements_delete, elements_rename = [])
          created_radio_names = Array.new
          elements_create.each do |attrs|
            name = attrs[:name]
            type = attrs[:type]
            raise_element_error({name: 'create element name is blank'}) unless name.present?
            if type == 'radio'
              next if created_radio_names.include?(name)
              created_radio_names.push(name)
            end
            element = element_class.new
            raise_element_error({element_type: "#{type.inspect} is not supported"}) unless element.is_supported_type?(type)
            element.componentable = @content
            element.name          = name
            element.element_type  = type
            raise_element_error(element.errors, name)  unless element.save
          end
          # As of 06/05/2014, rename functionality has not been implemented on the ember side.
          elements_rename.each do |attrs|
            element = get_existing_element(attrs[:id])
            name    = attrs[:name]
            raise_element_error({name: 'rename element name is blank'}) unless name.present?
            element.name     = name
            raise_element_error(element.errors, name)  unless element.save
          end
          elements_delete.each do |attrs|
            id   = attrs[:id]
            type = attrs[:type]
            raise_element_error({id: 'destroy element id is blank'}) unless id.present?
            raise_element_error({id: "destroy element type for id #{id} is blank"}) unless type.present?
            element = get_existing_element(id)
            raise_element_error(element.errors)  unless element.destroy
          end
        end

        # Find the element through the @content.  Will raise 'record not found' error if id not valid for the content.
        def get_existing_element(id)
          raise "Input element ID is blank for html content #{@content.inspect}." unless id.present?
          @content.thinkspace_input_element_elements.find(id)
        end

        def raise_element_error(messages, name=nil)
          messages.each do |attribute, error|
            error += " [#{name}]"  if name.present? && attribute == :name
            @content.errors.add(attribute, error)
          end
          raise ProcessInputElementError
        end

        # ###################################
        # ### Validate Tags
        # ###################################

        def validate_html_content(new_html)
          action = totem_action_authorize.action
          raise_access_denied_exception('Params and record authable to not match.', action, @content) unless totem_action_authorize.params_authable == totem_action_authorize.record_authable
          raise_access_denied_exception('Cannot update html content.', action, @content) unless totem_action_authorize.can_update_record_authable?

          # Parse the old and new html tags into an array of nokogiri tag nodes.
          element_tags = element_class.element_tags
          custom_tags  = element_class.custom_tags
          image_tags   = :img

          old_tags = parse_html_tags(@content.html_content, element: element_tags, custom: custom_tags)  # custom tags used for create/delete info only
          new_tags = parse_html_tags(new_html,              element: element_tags, custom: custom_tags, image: image_tags)
          # Get any new html nokogiri errors not related to a custom tag.
          ng_errors  = new_tags[:errors].select {|e| !([801, 76].include?(e.code) && custom_tags.include?(e.str1))}
          errors     = ng_errors.collect {|e| {message: e.message, line: e.line, key: :base} }

          # Validate the tags and collect the errors.
          errors += validate_element_tags new_tags[:element]
          errors += validate_custom_tags  new_tags[:custom]
          errors += validate_image_tags   new_tags[:image]
          # Sort errors by line number.
          errors  = errors.sort_by {|e| e[:line]}

          hash = Hash.new
          case action
          when :validate
            if errors.present?
              hash[:errors] = errors
            else
              element     = get_element_tag_changes(old_tags[:element], new_tags[:element])
              custom      = get_custom_tag_changes(old_tags[:custom], new_tags[:custom])
              all_changes = element[:create] + element[:delete] + custom[:create] + custom[:delete]
              hash[:changes] = all_changes.sort_by { |change| [change[:line], change[:action]] }
            end
          when :update
            # If the html was 'validated' before saving, then there should not be any errors.
            # If there are errors and since this is an update, treat them as model validation errors.
            if errors.present?
              errors.each do |error|
                attribute = error[:key] || :base
                message   = error[:message]
                @content.errors.add(attribute, message)
              end
              raise ProcessInputElementError
            else
              changes = get_element_tag_changes(old_tags[:element], new_tags[:element])
              hash[:create] = changes[:create]
              hash[:delete] = changes[:delete]
            end
          else
            raise "Unknown content validation action [#{action.inspect}]."
          end

          hash
        end

        def parse_html_tags(html_string, tag_hash)
          html = ::Nokogiri::HTML.fragment(html_string) do |config|
            config.strict.nonet
          end
          hash = Hash.new
          tag_hash.each do |key, tags|
            hash[key] = get_tags(html, tags)
          end

          # Check for tags that Nokogiri deems invalid, yet are actually valid.
          # => Could not find an option for the parser to skip things like 'canvas' tags, so handling it this way.
          errors          = []
          skip_error_tags = ['canvas']
          html.errors.each do |error|
            errors << error unless skip_error_tags.include?(error.str1) # error.str1 # 'canvas'
          end

          hash[:errors] = errors
          hash
        end

        def validate_element_tags(element_tags)
          errors           = Array.new
          radio_tags, tags = element_tags.partition {|tag| tag['type'] == 'radio'}
          validate_element_radio_tags(radio_tags, tags, errors)
          names    = get_tags_attribute(tags, :name)
          bad_tags = tags.find_all {|tag| tag['name'].present? && names.count(tag['name']) > 1}
          add_tag_errors(errors, bad_tags, ":tag.name :tag_name is a duplicate")
          # the below validations apply to all tags
          tags    += radio_tags
          bad_tags = tags.find_all {|tag| invalid_tag_name(tag['name'])}
          add_tag_errors(errors, bad_tags, ":tag.name :tag_name is invalid")
          bad_tags = tags.find_all {|tag| tag['id'].present?}
          add_tag_errors(errors, bad_tags, ":tag.name should not contain an id in :tag_name")
          input_types = ['text', 'checkbox', 'radio']
          bad_tags    = tags.find_all {|tag| tag.name == 'input' && tag['type'].present? && !input_types.include?(tag['type'])}
          add_tag_errors(errors, bad_tags, ":tag.name :tag_type invalid -> valid: #{input_types.inspect}", sub: :type)
          validate_tags_terminated(tags, errors)
          errors
        end

        def validate_element_radio_tags(radio_tags, other_tags, errors)
          radio_values = Hash.new
          radio_names  = Hash.new(0)
          radio_tags.each do |tag|
            name  = tag['name']
            value = tag['value']
            radio_values[name] ||= Array.new
            add_tag_errors(errors, tag, ":tag.name :tag_type :tag_name must include a value attribute", sub: :type)  if value.blank?
            add_tag_errors(errors, tag, ":tag.name :tag_type :tag_name has a duplicate value #{value.inspect}", sub: :type)  if radio_values[name].include?(value)
            radio_values[name].push(value)
            radio_names[name] += 1
          end
          other_names = other_tags.map {|tag| tag['name']}
          names       = radio_names.keys.sort
          dup_names   = names & other_names
          bad_tags    = radio_tags.select {|tag| dup_names.include?(tag['name'])}
          add_tag_errors(errors, bad_tags, ":tag.name :tag_type :tag_name is a duplicate of another input name", sub: :type)
          (names - dup_names).each do |name|
            count = radio_names[name]
            next if count > 1
            bad_tags = radio_tags.select {|tag| tag['name'] == name}
            # Add a validation error for a single radio button (e.g. one radio input with a name).
            # Technically, a single radio button would be ok but should be a checkbox instead.
            add_tag_errors(errors, bad_tags, ":tag.name :tag_type :tag_name is a single radio button", sub: :type)
          end
        end

        def validate_custom_tags(tags)
          errors = Array.new
          tags.each do |tag|
            tag_errors = Array.new
            id         = tag['id']
            type       = tag['type']
            template   = tag['template']
            add_tag_errors(tag_errors, tag, ":tag.name :tag_name should not contain an id")  if id.present?
            add_tag_errors(tag_errors, tag, ":tag.name :tag_template is invalid", sub: :template)  if template.present? && invalid_tag_name(template)
            valid_types     = element_class.custom_tag_types(tag.name)
            valid_templates = element_class.custom_tag_type_templates(tag.name, type)
            unless valid_types.include?(type)
              add_tag_errors(tag_errors, tag, ":tag.name :tag_type invalid -> valid: #{valid_types.inspect}", sub: :type)
            end
            if template.present? && !valid_templates.include?(template)
              add_tag_errors(tag_errors, tag, ":tag.name :tag_template invalid -> valid: #{valid_templates.inspect}", sub: :template)
            end
            if tag_errors.blank?  # do specific checks if tag is clean to this point
              case type.to_sym
              when :carry_forward
                name    = tag['name']
                element = totem_action_authorize.get_carry_forward_elements(name)
                add_tag_errors(tag_errors, tag, ":tag.name :tag_name is invalid")  if invalid_tag_name(name)
                add_tag_errors(tag_errors, tag, ":tag.name :tag_name for :tag_type not found", sub: :type)  if element.blank?
              when :carry_forward_image
              else
                add_tag_errors(tag_errors, tag, ":tag.name :tag_type not supported", sub: :type)
              end
            end
            errors += tag_errors
          end
          validate_tags_terminated(tags, errors)
          errors
        end

        def validate_tags_terminated(tags, errors)
          tags.each do |tag|
            child = tag.child
            add_tag_errors(errors, tag, ":tag.name not terminated for :tag_name (add: </#{tag.name}>)")  unless child.nil?
          end
        end

        def validate_image_tags(tags)
          errors = Array.new
          tags.each do |tag|
            src = tag['src']
            add_tag_errors(errors, tag, "Image tag should use 'https:'")  if src.match('http:')
          end
          errors
        end

        def get_element_tag_changes(old_tags, new_tags)
          hash          = Hash.new
          old_names     = get_tags_attribute(old_tags, :name).compact.uniq
          new_names     = get_tags_attribute(new_tags, :name).compact.uniq
          create_names  = new_names - old_names
          delete_names  = old_names - new_names
          create_tags   = get_tags_with_attribute_values(new_tags, :name, create_names)
          hash[:create] = create_tags.collect { |tag| {name: tag['name'], type: tag['type'] || tag.name, line: tag.line, action: :create, tag: tag.name} }
          hash[:delete] = Array.new
          deleted_radio_names = Array.new
          delete_names.each do |name|
            elements = @content.thinkspace_input_element_elements.where(name: name)
            raise ProcessInputElementError, "Element #{name.inspect} does not exist for content [id: #{@content.id}."  if elements.blank?
            raise ProcessInputElementError, "More than one element exists for #{name.inspect} content [id: #{@content.id}."  if elements.length > 1
            element = elements.first
            tags    = get_tags_with_attribute_values(old_tags, :name, name)
            raise ProcessInputElementError, "Delete element not found with name #{name.inspect} content [id: #{@content.id}."  if tags.blank?
            types = tags.map {|tag| tag['type']}.uniq
            if types == ['radio']
              next if deleted_radio_names.include?(name)
              deleted_radio_names.push(name)
            else
              raise ProcessInputElementError, "Delete has multiple elements with the same name #{name.inspect} content [id: #{@content.id}."  if tags.length > 1
            end
            tag = tags.first
            hash[:delete].push({id: element.id, name: element.name, type: element.element_type, line: tag.line, action: :delete, tag: tag.name})
          end
          hash
        end

        def get_custom_tag_changes(old_tags, new_tags)
          hash          = Hash.new
          old_names     = get_tags_attribute(old_tags, :name).compact.uniq
          new_names     = get_tags_attribute(new_tags, :name).compact.uniq
          create_names  = new_names - old_names
          delete_names  = old_names - new_names
          create_tags   = get_tags_with_attribute_values(new_tags, :name, create_names)
          hash[:create] = create_tags.collect { |tag| {name: tag['name'], type: tag['type'] || tag.name, line: tag.line, action: :create, tag: tag.name} }
          delete_tags   = get_tags_with_attribute_values(old_tags, :name, delete_names)
          hash[:delete] = delete_tags.collect { |tag| {name: tag['name'], type: tag['type'] || tag.name, line: tag.line, action: :delete, tag: tag.name} }
          hash
        end

        # ###
        # ### Validate Tag Helpers
        # ###

        def valid_tag_name(name)
          return false if name.blank?
          name.match(/^[a-zA-Z0-9_-]+$/)
        end

        def invalid_tag_name(name); !valid_tag_name(name); end

        def get_tags(*args)
          html      = args.shift
          tag_names = [args].flatten
          tags      = Array.new
          tag_names.each do |tag_name|
            tags += html.css(tag_name.to_s)
          end
          tags
        end

        def get_tags_attribute(tags, key)
          key = key.to_s
          tags.collect {|tag| tag[key]}
        end

        def get_tags_with_attribute_values(tags, key, values)
          key    = key.to_s
          values = [values].flatten.compact
          tags.select {|tag| values.include?(tag[key])}
        end

        def add_tag_errors(errors, tags, message, options={})
          return if tags.blank?
          [tags].flatten.each do |tag|
            msg = tag_error_message(tag, message, options)
            key = options[:sub].blank? ? :name : [options[:sub]].flatten.join('_').to_sym
            errors.push({message: msg, line: tag.line, key: key})
          end
        end

        def tag_error_message(tag, message, options={})
          subs = [options[:sub], :name].flatten.compact.uniq
          subs.uniq.each do |sub|
            sub_string = ":tag_#{sub}"
            sub_value  = tag[sub.to_s]
            sub_value  = sub_value.present? ? sub_value.inspect : 'missing'
            message    = message.sub(sub_string, "#{sub} #{sub_value}")
          end
          message = message.sub(':tag.name', tag.name)  if message.match(':tag.name')
          message
        end

        # # This would only be an approximation based on whether the tag paths are the same
        # # and only work for simple changes.  Does not work when multiple changes impact a tag's path.
        # def get_tag_rename_changes(old_tags, new_tags, deleted_names)
        #   renamed      = Array.new
        #   delete_tags  = get_tags_with_attribute_values(old_tags, :name, deleted_names).compact.uniq
        #   delete_paths = delete_tags.collect {|tag| tag.path}
        #   delete_paths.each do |path|
        #     rename_tags  = new_tags.select {|tag| path == tag.path}
        #     if rename_tags.present?
        #       rename_names = get_tags_attribute(rename_tags, :name)
        #       renamed     += rename_names
        #     end
        #   end
        #   renamed.compact.uniq
        # end

        # ###
        # ### General Helpers
        # ###

        def element_class; Thinkspace::InputElement::Element; end

        class ProcessInputElementError < StandardError; end

      end
    end
  end
end
