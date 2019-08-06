module Thinkspace
  module PeerAssessment
    module Concerns
      module SerializerOptions
        module Assessments

          def show(serializer_options)
            serializer_options.blank_association :thinkspace_peer_assessment_review_sets
          end

          def select(serializer_options) show(serializer_options); end

          def view(serializer_options)
            case serializer_options.sub_action
            when :teams
              serializer_options.remove_all
            when :review_sets
              serializer_options.include_association :thinkspace_peer_assessment_reviews
            end
          end

          def team_members(serializer_options); end
          def reviews(serializer_options); end

        end
      end
    end
  end
end
