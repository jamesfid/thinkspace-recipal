module Thinkspace
  module WeatherForecaster
    module ItemXml
      module SupportClasses
    
        # ###
        # ### Responses.
        # ###

        class BaseResponse
          attr_reader :id
          attr_reader :response
          attr_reader :validations

          def initialize(id)
            raise XMLResponseError, "#{self.class.name} response item id is blank."  if id.blank?
            @response        = ActiveSupport::OrderedOptions.new
            @validations     = ActiveSupport::OrderedOptions.new
            @id              = id
            response.choices = Array.new
          end
          def timing(val); response.timing = val; end

          def validation_temperature(min=-50, max=150); validation_input_min_max(min, max); end
          def validation_wind_speed(min=-50, max=200);  validation_input_min_max(min, max); end
          def validation_input_min_max(min=0, max=1)
            numericality                          = validations.numericality = ActiveSupport::OrderedOptions.new
            numericality.only_integer             = true
            numericality.greater_than_or_equal_to = min
            numericality.less_than_or_equal_to    = max
          end

          def validation_checkbox_require_min_max(min=1, max=nil)
            length = validations.length = ActiveSupport::OrderedOptions.new
            length.minimum = min
            length.maximum = max  if max.present?
          end
        end

        class RadioResponse < BaseResponse
          def add_choice(values)
            raise XMLResponseError, "Choice values must be a hash."  unless values.is_a?(Hash)
            values.symbolize_keys!
            id = values[:id]
            raise XMLResponseError, "Choice must contain an id #{values.inspect}."  unless id.present?
            raise XMLResponseError, "Choice with [id: #{id}] is a duplicate #{values.inspect}."  if response.choices.find {|c| c.id == id}
            response.choices.push ActiveSupport::OrderedOptions[values]
          end
          def metadata
            hash           = Hash.new
            hash[:type]    = 'radio'
            hash[:choices] = response.choices
            hash
          end
        end

        class CheckboxResponse < RadioResponse
          def metadata
            hash               = super
            hash[:type]        = 'checkbox'
            hash[:validations] = validations.to_hash  if validations.present?
            hash
          end
        end

        class InputResponse < BaseResponse
          def label(id, text)
            response.id    = id
            response.label = text
          end
          def prompt(val);  response.prompt  = val; end
          def columns(val); response.columns = val; end
          def value(val);   response.value   = val; end
          def type(val);    response.type    = val; end
          def metadata
            hash              = Hash.new
            hash[:type]       = 'input'
            hash[:attributes] = {
              columns: response.columns,
              prompt:  response.prompt,
              value:   response.value,
              type:    response.type,
            }
            hash[:validations] = validations.to_hash  if validations.present?
            hash
          end
        end

        # ###
        # ### Processing.
        # ###

        class ProcessorItem
          attr_reader :value
          def initialize
            @value = ActiveSupport::OrderedOptions.new
          end
          def response_qid(val);  exists?(:response_qid); value.response_qid = val; end
          def correct(val);       exists?(:correct);      value.correct = val; end
          def incorrect(val);     exists?(:incorrect);    value.incorrect = val; end
          def var(val);           exists?(:var);          value.var = val; end

          def exists?(key)
            raise XMLProcessorError, 'Attempting to over write an existing value for #{key.inspect}'  if value.has_key?(key.to_sym)
          end

        end

        class XMLResponseError  < StandardError; end
        class XMLProcessorError < StandardError; end

      end
    end
  end
end
