module Thinkspace
  module PeerAssessment
    module Api
      module Admin
        class AssessmentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_serializer_options
          before_action :authorize_authable, except: [:fetch]
          before_action :set_state_error_variables

          include Thinkspace::PeerAssessment::Concerns::StateErrors

          def update
            access_denied_state_error :update if @assessment.active?
            @assessment.value = params_root[:value]
            if @assessment.save
              controller_render_no_content
            else
              controller_render(@assessment)
            end
          end

          def activate
            access_denied_state_error :activate unless @assessment.may_activate?
            phase = @assessment.authable
            teams = phase.thinkspace_team_teams
            access_denied "No teams are assigned to phase [#{phase.id}].", 'There are no teams assigned to this phase.  Please assign a team and try again.' if teams.blank?
            @assessment.activate!
            controller_render(@assessment)
          end

          def approve
            access_denied_state_error :approve unless @assessment.may_approve?
            @assessment.approve!
            controller_render(@assessment)
          end

          def teams
            teams = Thinkspace::Team::Team.scope_by_teamables(@assessment.authable)
            controller_render(teams)
          end

          def review_sets
            team_id     = params[:team_id]
            team        = Thinkspace::Team::Team.find_by(id: team_id)
            authorize! :update, team.authable
            team_set    = Thinkspace::PeerAssessment::TeamSet.find_or_create_by(team_id: team_id, assessment_id: @assessment.id)
            review_sets = team_set.thinkspace_peer_assessment_review_sets
            controller_render(review_sets)
          end

          def team_sets
            team_ids          = Thinkspace::Team::Team.scope_by_teamables(@assessment.authable).pluck(:id)
            assessment_id     = @assessment.id
            team_sets         = Thinkspace::PeerAssessment::TeamSet.where(assessment_id: assessment_id, team_id: team_ids)
            existing_team_ids = team_sets.pluck(:team_id)
            create_team_ids   = team_ids - existing_team_ids
            create_team_ids.each { |id| Thinkspace::PeerAssessment::TeamSet.create(assessment_id: assessment_id, team_id: id) }
            team_sets.reload unless create_team_ids.empty?
            controller_render(team_sets)
          end

          def fetch
            assignment_id = params[:assignment_id]
            assignment    = Thinkspace::Casespace::Assignment.find(assignment_id)
            authorize! :update, assignment
            phase_ids   = assignment.thinkspace_casespace_phases.scope_active.pluck(:id)
            assessments = Thinkspace::PeerAssessment::Assessment.where(authable_type: 'Thinkspace::Casespace::Phase', authable_id: phase_ids).limit(1)
            assessments.empty? ? controller_render([]) : controller_render(assessments.first)
          end

          def notify
            message = params[:notification]
            user_id = params[:user_id]
            access_denied("Invalid user_id [#{user_id}] for assessment [#{@assessment.id}]", 'Invalid notification request.') unless user_id_is_on_assessment?(user_id)
            Thinkspace::PeerAssessment::AssessmentMailer.notify_ownerable(@assessment, @user, message).deliver_now
            controller_render(@assessment)
          end

          def notify_all
            @assessment.notify_all_incomplete
            controller_render(@assessment)
          end

          private

          def access_denied(message, user_message='')
            raise_access_denied_exception(message, self.action_name.to_sym, @user || controller_model_class_name, user_message: user_message)
          end

          def user_id_is_on_assessment?(user_id)
            return false unless user_id
            authable = @assessment.authable
            return false unless authable
            space = authable.get_space
            return false unless space
            @user = Thinkspace::Common::User.find_by(id: user_id)
            return false unless @user
            space.is_space_user?(@user)
          end

          def authorize_authable
            authorize! :update, @assessment.authable
          end

          def set_state_error_variables
            @model        = @assessment
            @model_name   = 'an assessment'
            @model_class  = @model.class.name
          end

        end
      end
    end
  end
end
