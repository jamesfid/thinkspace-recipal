module Thinkspace
  module ObservationList
    module Concerns
      module SerializerOptions
        module Observations

            def common_options(serializer_options)
              serializer_options.remove_association(:ownerable)
              serializer_options.ability_actions(:update, :destroy, scope: :root)
            end

            def create(serializer_options)
              common_options(serializer_options)
            end

            def update(serializer_options)
              common_options(serializer_options)
            end

            def destroy; end

        end
      end
    end
  end
end