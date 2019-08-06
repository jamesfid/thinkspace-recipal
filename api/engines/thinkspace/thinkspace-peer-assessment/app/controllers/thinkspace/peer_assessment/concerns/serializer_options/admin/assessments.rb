module Thinkspace
  module PeerAssessment
    module Concerns
      module SerializerOptions
        module Admin
          module Assessments

            def update(serializer_options); end

            def teams(serializer_options)
              serializer_options.include_association :thinkspace_common_users, scope: :root # Root are teams.
              serializer_options.include_association :thinkspace_peer_assessment_team_sets
              serializer_options.remove_all scope: :thinkspace_common_users
            end

            def fetch(serializer_options)
              serializer_options.remove_association :thinkspace_peer_assessment_review_sets
            end
            
            def review_sets(serializer_options)
              serializer_options.include_association :thinkspace_peer_assessment_reviews
            end

            def team_sets(serializer_options); end

            def approve(serializer_options); end
            def activate(serializer_options)
              serializer_options.include_association :authable, scope: :root
            end

            def notify(so); end
            def notify_all(so); end

          end
        end
      end
    end
  end
end
