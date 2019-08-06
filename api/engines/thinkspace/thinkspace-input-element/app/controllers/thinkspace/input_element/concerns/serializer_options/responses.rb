module Thinkspace
  module InputElement
    module Concerns
      module SerializerOptions
        module Responses

          def common_serializer_options(serializer_options)
            serializer_options.remove_association  :ownerable
            serializer_options.remove_association  :thinkspace_common_user
          end

          def create(serializer_options)
            common_serializer_options(serializer_options)
          end

          def update(serializer_options)
            common_serializer_options(serializer_options)
          end

          def carry_forward(serializer_options)
            common_serializer_options(serializer_options)
            serializer_options.remove_association  :componentable
          end

        end
      end
    end
  end
end
