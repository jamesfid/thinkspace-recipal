module Thinkspace
  module WeatherForecaster
    module ItemXml
      module Isu

        def process(xml)
          doc = parse_xml(xml)
          set_default_id_key('ident')
          extract_items(doc)
        end

        def extract_items(doc)
          items = doc.css('item')
          items.each do |item|
            title = get_attr(item, :title)
            next if title.match(/reporting station/i)
            result       = new_item
            result.title = title
            result.id    = get_id(item)
            presentation = item.css('presentation')
            add_item(result, presentation)
            add_processing(result, item)
            add_response(result, presentation)
            parser_items.push result
          end
        end

        def add_item(result, presentation)
          material = presentation.css('material').first
          item     = material.css('mattext')
          content  = item.present? ? sanitize_string(item.text) : ''
          header   = nil
          help_tip = nil

          if content.match('<h')
            names           = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']
            content, header = extract_content_and_name_text(content, names)
            content         = content.gsub(/<br>/i, '')
          end
          if content.match('<a')
            names            = ['a']
            content, anchors = extract_content_and_name_text(content, names)
            html             = parse_html(anchors)
            html.children.each do |child|
              result.add_help_tip_html "<h4>#{child.text}</h4>"
            end
          end
          result.content  = content
          # result.header   = header
        end

        def known_outcome_keys; [:vartype, :defaultval, :varname, :maxvalue, :minvalue]; end
        def known_condition_names; [:conditionvar, :text, :setvar]; end

        def add_processing(result, item)
          processing   = item.css('resprocessing')
          outcome      = processing.css('outcomes decvar').first
          conditions   = processing.css('respcondition')
          processor    = result.processor
          unknown_keys = (outcome.keys.map {|k| k.to_sym}) - known_outcome_keys
          raise XMLError, "Unknown process outcome keys #{unknown_keys} in \n#{outcome.to_xml}"  if unknown_keys.present?
          default_value = get_attr(outcome, :defaultval, 0).to_i
          unknown_names = (conditions.children.map {|c| c.name.to_sym}) - known_condition_names
          raise XMLError, "Unknown process condition names #{unknown_names} in \n#{conditions.to_xml}"  if unknown_names.present?
          condition_var = conditions.css('conditionvar')
          set_var       = conditions.css('setvar')
          condition_var.children.each do |child|
            case child.name.downcase
            when 'varequal'
              id    = get_id(child, 'respident')
              value = condition_text_to_hash(child.text)
              processor.var(value.var)
              processor.response_qid(value.site)
            when 'text'
              raise XMLError, "Unknown condition text value #{child.name.inspect} in \n#{child.to_xml}"  unless sanitize_string(child.text).blank?
            else
              raise XMLError, "Unknown condition #{child.name.inspect} in \n#{child.to_xml}"
            end
          end

          add_value = 0
          set_var.each do |var|
            name   = get_attr(var, :varname)
            action = get_attr(var, :action)
            value  = var.text
            case action.downcase
            when 'add'
              raise XMLError, "Duplicate add value #{value.inspect} for var #{var.to_s.inspect}"  if add_value > 0
              raise XMLError, "Add value #{value.inspect} for var #{var.to_s.inspect} is not an integer."  unless is_integer?(value)
              add_value = value.to_i
            else
              raise XMLError, "Unknown action #{name.inspect} in \n#{var.to_s}"
            end
          end

          processor.incorrect(default_value)
          processor.correct(default_value + add_value)
        end

        def condition_text_to_hash(text)
          hash = ActiveSupport::OrderedOptions.new
          return hash if text.blank?
          var_str = text.sub(/^\{/, '').sub(/\}$/, '')
          vars    = var_str.split(',').map {|v| v.strip}
          vars.each do |var|
            key, value = var.split('=', 2)
            if value.match(';')
              value = value.split(';')
            end
            hash[key.to_sym] = value
          end
          hash
        end

        def add_response(result, presentation)
          var             = result.processing.value.var
          response        = presentation.children.select {|node| node.name.start_with?('response')}.first
          response_id     = get_id(response)
          response_timing = get_attr(response, :rtiming).downcase

          case response.name.downcase

          when 'response_str'
            input = result.input(response_id)
            input.timing(response_timing)
            render = response.css('render_fib')
            label  = render.css('response_label').first
            input.type    get_attr(render, :fibtype).downcase
            input.columns get_attr(render, :columns)
            input.value   get_attr(render, :value)
            input.label   get_id(label), label.text
            case
            when is_temperature?(var)
              input.validation_temperature
            when is_wind_speed?(var)
              input.validation_wind_speed
            end

          when 'response_lid'
            cardinality = get_attr(response, 'rcardinality').downcase
            case cardinality
            when 'single'
              radio = result.radio(response_id)
              radio.timing(response_timing)
              labels = response.css('response_label')
              labels.each do |label|
                qid    = get_id(label)
                id     = get_id_from_qid(qid)
                label  = label.css('mattext').text
                choice = {id: id, label: label, qid: qid}
                add_choice_actual_id(var, choice)
                radio.add_choice(choice)
              end
            when 'multiple'
              checkbox = result.checkbox(response_id)
              checkbox.timing(response_timing)
              labels   = response.css('response_label')
              labels.each do |label|
                qid    = get_id(label)
                id     = get_id_from_qid(qid)
                label  = label.css('mattext').text
                choice = {id: id, label: label, qid: qid}
                add_choice_actual_id(var, choice)
                checkbox.add_choice(choice)
              end
            else
              raise XMLError, "Unknown response cardinality #{cardinality.inspect} in \n#{response.to_xml}"
            end

          else
          end
        end

        def add_choice_actual_id(var, choice)
          if is_wind_direction?(var)
            prev_id            = choice[:id]
            choice[:id]        = choice[:label]
            choice[:actual_id] = prev_id
          end
        end

        def is_wind_speed?(var);     var.match(/^WSPD/i); end
        def is_wind_direction?(var); var.match(/^WDIR/i); end
        def is_temperature?(var);    var.match(/^TEMP/i); end

      end
    end
  end
end

