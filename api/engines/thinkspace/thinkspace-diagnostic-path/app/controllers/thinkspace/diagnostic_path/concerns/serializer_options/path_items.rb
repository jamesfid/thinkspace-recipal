module Thinkspace
  module DiagnosticPath
    module Concerns
      module SerializerOptions
        module PathItems

          # def common_serializer_options(serializer_options)
          #   serializer_options.remove_association  :ownerable
          #   serializer_options.remove_association  :thinkspace_common_user

          #   serializer_options.include_ability(
          #       scope:   :root,
          #       create:  serializer_options.ownerable_ability[:create],
          #       destroy: serializer_options.ownerable_ability[:destroy],
          #     )
          # end

          def common_serializer_options(serializer_options)
            serializer_options.remove_association  :authable
            serializer_options.remove_association  :ownerable
            serializer_options.remove_association  :path_itemable
            serializer_options.remove_association  :thinkspace_common_user

            serializer_options.include_ability(
                create:  serializer_options.ownerable_ability[:create],
                destroy: serializer_options.ownerable_ability[:destroy],
              )
          end

          def create(serializer_options)
            common_serializer_options(serializer_options)
          end

          def show(serializer_options)
            common_serializer_options(serializer_options)
          end

          def update(serializer_options)
            common_serializer_options(serializer_options)
          end

          def destroy; end

        end
      end
    end
  end
end
