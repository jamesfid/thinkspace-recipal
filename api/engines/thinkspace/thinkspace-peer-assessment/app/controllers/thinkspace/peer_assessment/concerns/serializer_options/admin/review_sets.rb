module Thinkspace
  module PeerAssessment
    module Concerns
      module SerializerOptions
        module Admin
          module ReviewSets

            def approve(serializer_options); state_change(serializer_options); end
            def unapprove(serializer_options); state_change(serializer_options); end
            def ignore(so); state_change(so); end
            def approve_all(so); state_change(so); end
            def unapprove_all(so); state_change(so); end

            def state_change(serializer_options)
              serializer_options.include_association :thinkspace_peer_assessment_reviews
            end
            
          end
        end
      end
    end
  end
end
