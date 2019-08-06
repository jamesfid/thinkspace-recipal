module Thinkspace
  module Artifact
    module Api
      class FilesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class, except: [:create]
        before_filter :set_ownerable, only: [:create]
        totem_action_authorize! except: [:create]
        totem_action_serializer_options

        def create
          attachments = params[:files] # jQuery-File-Upload expects the input to be named 'files'
          bucket_id   = params[:bucket_id]
          access_denied(default_error_text) unless current_user.present?
          access_denied(default_error_text) unless attachments.present? and bucket_id.present?

          # Ensure bucket exists and user can read it (meaning they have access to the phase).
          bucket  = Thinkspace::Artifact::Bucket.find(bucket_id)
          access_denied(default_error_text) unless bucket.present?
          ability = platform_ability(bucket)
          access_denied(default_error_text) if not ability
          ability.authorize!(:read, bucket)
          created_files = []
          # TODO: This needs to support ownerable not being user.
          # => This is set as is because of the jQuery file upload not having access to things like: totem_scope.set_record_ownerable_attributes, etc.
          attachments.each do |attachment|
            file = Thinkspace::Artifact::File.new(attachment: attachment, thinkspace_common_user: current_user, thinkspace_artifact_bucket: bucket, ownerable: @ownerable)
            if file.save
              created_files << file
            else
              access_denied(file.errors)
            end
          end
          controller_render(created_files)
        end

        def show
          controller_render(@file)
        end

        def select
          controller_render(@files)
        end

        def destroy
          ability = platform_ability(@file)
          ability.authorize!(:destroy, @file)
          controller_destroy_record(@file)
        end

        def image_url
          action = :image_url
          render_file_image_url(@file, action)
        end

        def carry_forward_image_url
          action    = :carry_forward_image
          phase     = totem_action_authorize.params_authable
          ownerable = totem_action_authorize.params_ownerable
          file      = get_carry_forward_file(phase, ownerable, action)
          render_file_image_url(file, action)
        end

        def carry_forward_expert_image_url
          action    = :carry_forward_expert_image
          phase     = totem_action_authorize.params_authable
          is_expert = phase.settings['artifact_expert'] == true
          access_denied("Carry forward expert image for phase [id: #{phase.id}] is not an 'artifact_expert: true'.", action, phase) unless is_expert
          ownerable = get_phase_owner(phase)
          file      = get_carry_forward_file(phase, ownerable, action)
          render_file_image_url(file, action)
        end

        private

        def access_denied(message, action=:create, records=nil)
          raise_access_denied_exception(message, action, records)
        end

        def set_ownerable
          bucket         = Thinkspace::Artifact::Bucket.find(params[:bucket_id])
          access_denied("No bucket was found.") unless bucket.present?
          ownerable_type = params[:ownerable_type]
          ownerable_id   = params[:ownerable_id]
          access_denied("No ownerable was found.")    unless (ownerable_type.present? && ownerable_id.present?)
          access_denied("Ownerable type is invalid.") unless (ownerable_type == 'thinkspace/team/team' || ownerable_type == 'thinkspace/common/user')
          klass = ownerable_type.classify.safe_constantize
          access_denied("Invalid ownerable_type [#{ownerable_type}]") unless klass.present?

          case ownerable_type
          when 'thinkspace/team/team'
            team     = klass.find(ownerable_id)
            access_denied("Team was not found.") unless team.present?
            access_denied("Current user is not on the team.") unless Thinkspace::Team::Team.users_on_teams?(bucket.authable, current_user, team)
            @ownerable = team
          when 'thinkspace/common/user'
            user = klass.find(ownerable_id)
            access_denied("User is not found.") unless user.present?
            access_denied("User is not current user") unless user == current_user
            @ownerable = user
          end

        end

        def default_error_text
          'Invalid request for uploading a file.'
        end

        def render_file_image_url(file, action)
          if file.blank?
            controller_render_no_content
          else
            if ::Rails.env.production?
              url = file.attachment.url
            else
              url = file.attachment.path
              url = url.sub(/^public\//, "#{request.protocol}#{request.host_with_port}/")
            end
            controller_render_json({url: url})
          end
        end

        # ###
        # ### Carry Forward.
        # ###

        def get_carry_forward_file(phase, ownerable, action)
          access_denied "Carry forward auth-phase is blank.", action if phase.blank?
          access_denied "Carry forward auth-ownerable is blank.", action, phase if ownerable.blank?
          from_phase = params[:from_phase]
          access_denied "Carry forward files params[:from_phase] is blank.", action, phase if from_phase.blank?

          case from_phase
          when !String
            access_denied "Carry forward from_phase value is not a string. [#{hash.inspect}]", action, phase

          when /^\d+$/
            id_phase = ::Thinkspace::Casespace::Phase.find_by(id: from_phase)
            access_denied "Carry forward from_phase with [id: #{from_phase.inspect}] not found.", action, phase if id_phase.blank?
            get_artifact_file(id_phase, ownerable).first

          else
            access_denied "Carry forward from_phase is invalid. [from_phase: #{from_phase.inspect}]", action, phase
          end

        end

        def get_artifact_file(phase, ownerable)
          bucket_ids = ::Thinkspace::Artifact::Bucket.where(authable: phase).pluck(:id)
          ::Thinkspace::Artifact::File.where(bucket_id: bucket_ids, ownerable: ownerable)
        end

        # TODO: How should the 'expert' file 'ownerable' be determined (when phase.settings.artifact_expert == true)? For now defaulting to the phase owner.
        def get_phase_owner(phase)
          space      = phase.get_space
          space_user = space.thinkspace_common_space_users.where(role: :owner)
          space_user = space.thinkspace_common_space_users.where(role: :update) if space_user.blank?
          return nil if space_user.blank?
          ownerable = space_user.first.thinkspace_common_user
          access_denied "Carry forward 'expert' file_ownerable is blank.", :carry_forward, phase if ownerable.blank?
          ownerable
        end

      end
    end
  end
end
