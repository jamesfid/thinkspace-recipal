module Thinkspace
  module DiagnosticPath
    module Concerns
      module SerializerOptions
        module Paths

          def show(serializer_options)
            serializer_options.remove_association  :authable
            serializer_options.blank_association   :thinkspace_diagnostic_path_path_items
            serializer_options.include_ability(
                scope:   :root,
                update:  serializer_options.authable_ability[:update],
              )
          end

          def update(serializer_options)
            show(serializer_options)
          end

          def view(serializer_options)
            common_view_serializer_options(serializer_options)
            include_abilities(serializer_options, :thinkspace_diagnostic_path_path_items)
          end

          def bulk(serializer_options)
            common_view_serializer_options(serializer_options)
            include_abilities(serializer_options, :thinkspace_diagnostic_path_path_items)
          end

          def bulk_destroy(serializer_options)
          end

          def common_view_serializer_options(serializer_options)
            serializer_options.remove_association  :ownerable
            serializer_options.remove_association  :path_itemable
            serializer_options.remove_association  :thinkspace_common_user
            serializer_options.include_association :thinkspace_diagnostic_path_path_items, scope_association: :params_ownerable
          end

          # TODO: Investigate and fix.
          def include_abilities(serializer_options, scope=:root)
            serializer_options.include_ability(
                scope:   scope,
                create:  serializer_options.ownerable_ability[:create],
                destroy: serializer_options.ownerable_ability[:destroy],
              )
          end

        end
      end
    end
  end
end
