module Thinkspace
  module Markup
		module Api
		  class CommentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
				load_and_authorize_resource class: totem_controller_model_class
				before_filter :set_parent_in_params, only: [:create, :update]
				totem_action_authorize! only: [:create, :destroy, :update], ownerable_ability_action: :view, module: :action_authorize_markup,  allow_blank_associations: {create: [:parent_id], update: [:parent_id]}
				totem_action_authorize! only: [:fetch], read: [:fetch]

        def create
          # TODO: Authorize discussion.
          @comment.discussion_id = params_association_id(:discussion_id)
          @comment.comment       = params_root[:comment]
          @comment.commenterable = current_ability.get_record_by_model_type_and_model_id(params_root[:commenterable_type], params_root[:commenterable_id])
          @comment.user_id       = current_user.id
          controller_save_record(@comment)
        end

        def fetch
          # params[:auth] values:
          #   authable:    e.g. phase
          #   ownerable:   current team/user
          #   commentable: artifact being commented on (e.g. file)
          #   view_ids:    ids of user/team to view (e.g. get the comments for this team/user)
          #   view_type:   class of what to scope view_ids to (team/user)
          totem_action_authorize.process_view_action
          commentable     = current_ability.get_record_by_model_type_and_model_id(params[:auth][:commentable_type], params[:auth][:commentable_id])
          authable        = totem_action_authorize.params_authable
          view_ids        = totem_action_authorize.params_view_ids
          view_class_name = totem_action_authorize.params_view_class_name
          case
          when current_ability.can?(:update, authable)
            # Instructor role, show all
            @comments = controller_model_class.where(
              authable:       authable,
              ownerable_id:   view_ids,
              ownerable_type: view_class_name
            )
          when is_viewing_self? || is_viewing_team?
            # Viewing self, show all.
            @comments = controller_model_class.where(
              authable:       authable,
              ownerable_id:   view_ids,
              ownerable_type: view_class_name
            )
          else
            # Viewing someone else, scope to comments current_user left.
            @comments = controller_model_class.where(
              authable:       authable,
              commenterable:  current_user,
              ownerable_id:   view_ids,
              ownerable_type: view_class_name
            )
          end
          serializer_options.authorize_action    :read_commenterable, :commenterable, scope: :root # allow the `commenterable` user to be serialized
          serializer_options.include_association :commenterable
          serializer_options.remove_association  :ownerable      # instead are return as type & id attributes
          serializer_options.remove_association  :authable       # instead are return as type & id attributes
          serializer_options.remove_association  :commentable    # instead are return as type & id attributes
          serializer_options.remove_association  :thinkspace_common_user
          serializer_options.remove_association  :thinkspace_common_spaces, scope: :thinkspace_common_user
          # Need to include the :commenterable association to include the users in the json, but do not want it in each rendered 'comment' json.
          hash = controller_as_json(@comments)
          hash[controller_plural_path].each {|h| h.delete(:commenterable)}
          controller_render_json(hash)
        end

        def update
          @comment.comment = params_root[:comment]
          @comment.save
          #controller_save_record(@comment)
          controller_render_no_content
        end

        def destroy
          controller_destroy_record(@comment)
        end

        private

        def set_parent_in_params
          @comment.parent_id = params_association_id('parent_id')
        end

        def access_denied(message, action, records)
          raise_access_denied_exception(message, action, records)
        end

        def is_viewing_self?
          klass    = get_view_class
          view_ids = totem_action_authorize.params_view_ids
          id       = view_ids.first
          klass.find(id) == current_user
        end

        def is_viewing_team?
          team_class = Thinkspace::Team::Team
          klass      = get_view_class
          authable   = totem_action_authorize.params_authable
          return false unless klass == team_class
          view_ids = totem_action_authorize.params_view_ids
          id       = view_ids.first
          team     = klass.find(id)
          team_class.users_on_teams?(authable, current_user, team)
        end

        def get_view_class
          view_ids        = totem_action_authorize.params_view_ids
          view_class_name = totem_action_authorize.params_view_class_name
          access_denied("Cannot view more than one record at a time.", :fetch, nil) if view_ids.length > 1
          view_class = view_class_name.safe_constantize
          access_denied("View class [#{view_class_name}] is invalid.", :fetch, nil) unless view_class.present?
          view_class
        end

      end
    end
  end
end
