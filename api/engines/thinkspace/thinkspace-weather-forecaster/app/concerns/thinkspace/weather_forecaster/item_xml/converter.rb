module Thinkspace
  module WeatherForecaster
    module ItemXml

      class Converter

        def model_attributes(item)
          {
            name:              get_name(item),
            title:             get_title(item),
            description:       get_description(item),
            score_var:         get_score_var(item),
            presentation:      get_presentation(item),
            item_header:       get_item_header(item),
            response_metadata: get_response_metadata(item),
            processing:        get_processing(item),
            help_tip:          get_help_tip(item),
          }
        end

        def get_name(item)
          item.id
        end

        def get_title(item)
          item.title
        end

        def get_description(item)
          item.description
        end

        def get_presentation(item)
          content = item.content.strip
          raise ConvertError, "Item content is blank. item: #{item.inspect}."  if content.blank?
          content.strip
        end

        def get_item_header(item)
          item.header
        end

        def get_response_metadata(item)
          item.response.metadata
        end

        def get_score_var(item)
          item.processing.value.var
        end

        def get_processing(item)
          item.processing.value.except(:var)
        end

        def get_help_tip(item)
          item.help_tip.present? ? item.help_tip : nil
        end

        class ConvertError < StandardError; end

      end

    end
  end
end
