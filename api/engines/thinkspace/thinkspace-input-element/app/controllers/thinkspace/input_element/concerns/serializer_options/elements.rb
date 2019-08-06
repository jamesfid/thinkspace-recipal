module Thinkspace
  module InputElement
    module Concerns
      module SerializerOptions
        module Elements

          def show(serializer_options)
            serializer_options.remove_association :componentable
          end

        end
      end
    end
  end
end
