module Thinkspace
  module PeerAssessment
    module Api
      class AssessmentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options

        def show
          controller_render(@assessment)
        end

        def view
          # A student cannot view an assessment that is not active or approved.
          access_denied "Assessment is already approved.", user_message: 'This assessment has already been sent by your instructor.' if @assessment.approved?
          
          if !@assessment.active? && current_ability.cannot?(:update, @assessment.authable)
            access_denied "Assessment is not activated yet.", user_message: 'You cannot access this assessment yet, it has not been activated by your instructor.'
          end

          sub_action = totem_action_authorize.sub_action
          case sub_action
          when :teams
            teams
          when :review_sets
            review_sets
          else
            access_denied "Unknown assessment view sub action #{sub_action.inspect}"
          end
        end

        private

        def teams
          ownerable = totem_action_authorize.params_ownerable
          phase     = @assessment.authable
          teams     = Thinkspace::Team::Team.users_teams(phase, ownerable)
          access_denied "No teams found on phase for ownerable.", user_message: "You are not assigned to a team for this phase." unless teams.present?
          team      = teams.first
          access_denied "No team found on phase for ownerable." unless team.present?
          user_ids  = team.thinkspace_common_users.pluck(:id)
          json      = controller_as_json(team)
          json['thinkspace/team/team']['thinkspace/common/user_ids'] = user_ids
          json.merge! controller_as_json(team.thinkspace_common_users)
          controller_render_json(json)
        end

        def review_sets
          ownerable = totem_action_authorize.params_ownerable
          team_id   = params[:team_id]
          team      = Thinkspace::Team::Team.find(team_id)
          access_denied "Team is invalid or not assigned to correct teamable." unless team.present?
          access_denied "Ownerable is not a member of specified team" unless Thinkspace::Team::Team.users_on_teams?(@assessment.authable, ownerable, team)
          team_set   = Thinkspace::PeerAssessment::TeamSet.find_or_create_by(team_id: team_id, assessment_id: @assessment.id)
          review_set = Thinkspace::PeerAssessment::ReviewSet.find_or_create_by(ownerable: ownerable, team_set_id: team_set.id)
          review_set.create_reviews
          controller_render(review_set)
        end

        private

        def access_denied(message, options={})
          raise_access_denied_exception(message, totem_action_authorize.action, @assessment, options)
        end

      end
    end
  end
end
