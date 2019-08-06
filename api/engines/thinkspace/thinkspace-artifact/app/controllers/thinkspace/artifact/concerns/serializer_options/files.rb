module Thinkspace
  module Artifact
    module Concerns
      module SerializerOptions
        module Files

            def create(serializer_options)
              serializer_options.remove_association :ownerable
              serializer_options.remove_association :thinkspace_common_user
            end

            def show(serializer_options)
              serializer_options.remove_association  :ownerable
              serializer_options.remove_association  :thinkspace_common_user
              serializer_options.include_association :thinkspace_resource_tags
            end

            def select(serializer_options); show(serializer_options); end

            def destroy(serializer_options); end

            def secure_file(serializer_options); end

            def image_url(serializer_options); end

            def carry_forward_image_url(serializer_options); end

            def carry_forward_expert_image_url(serializer_options); end

        end
      end
    end
  end
end
