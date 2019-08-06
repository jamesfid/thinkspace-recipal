module Thinkspace
  module Lab
    module Concerns
      module SerializerOptions
        module Charts

            def common_options(serializer_options)
              serializer_options.remove_association  :ownerable
              serializer_options.remove_association  :authable
              serializer_options.include_association :thinkspace_lab_categories, scope: :root
              serializer_options.include_association :thinkspace_lab_results
              serializer_options.include_association :thinkspace_lab_observations, scope_association: :params_ownerable
            end

            def show(serializer_options)
              common_options(serializer_options)
            end

            def select(serializer_options); show(serializer_options); end

            def view(serializer_options)
              common_options(serializer_options)
            end

            def update(serializer_options)
              common_options(serializer_options)
            end

        end
      end
    end
  end
end
