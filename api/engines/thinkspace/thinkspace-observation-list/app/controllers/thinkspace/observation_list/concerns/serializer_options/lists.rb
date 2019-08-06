module Thinkspace
  module ObservationList
    module Concerns
      module SerializerOptions
        module Lists

            def common_options(serializer_options)
              serializer_options.remove_association  :authable
              serializer_options.remove_association  :ownerable
              serializer_options.remove_association  :thinkspace_common_user

              serializer_options.include_ability(
                  scope:   :thinkspace_observation_list_observations,
                  update:  serializer_options.ownerable_ability[:update],
                  destroy: serializer_options.ownerable_ability[:destroy],
                )
            end

            def show(serializer_options)
              common_options(serializer_options)
              serializer_options.blank_association   :thinkspace_observation_list_observations
              serializer_options.blank_association   :thinkspace_observation_list_observation_notes
              serializer_options.include_association :thinkspace_observation_list_lists, scope: :root
            end

            def select(serializer_options); show(serializer_options); end

            def view(serializer_options)
              common_options(serializer_options)
              serializer_options.include_association :thinkspace_observation_list_observations, scope_association: :params_ownerable
              serializer_options.include_association :thinkspace_observation_list_observation_notes
            end

            def observation_order; end

        end
      end
    end
  end
end
