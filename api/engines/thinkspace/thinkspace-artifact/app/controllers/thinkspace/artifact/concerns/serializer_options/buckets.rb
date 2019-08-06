module Thinkspace
  module Artifact
    module Concerns
      module SerializerOptions
        module Buckets

            def common_options(serializer_options)
              serializer_options.remove_association :authable
              serializer_options.remove_association :ownerable
              serializer_options.remove_association :thinkspace_common_user
            end

            def show(serializer_options)
              common_options(serializer_options)
              serializer_options.scope_association  :thinkspace_artifact_files, scope_association: :params_ownerable
            end

            def view(serializer_options)
              common_options(serializer_options)
              serializer_options.include_association :thinkspace_artifact_files, scope_association: :params_ownerable
            end

        end
      end
    end
  end
end
