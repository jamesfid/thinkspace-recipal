module Thinkspace
  module Markup
    module Api
      class LibraryCommentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        #totem_action_authorize! only: [:create, :destroy, :update], ownerable_ability_action: :view, module: :action_authorize_markup

        def select 
          @library_comments = @library_comments.where(id: params[:ids])
          controller_render(@library_comments)
        end

        def show
          controller_render(@library_comment)
        end

        def create
          @library_comment.user_id            = current_user.id
          @library_comment.comment            = params_root[:comment]
          if params_root[:uses] != nil
            @library_comment.uses             = params_root[:uses]
          else
            @library_comment.uses             = 0
          end
          @library_comment.last_used          = params_root[:last_used]
          @library_comment.library_id         = params_association_id(:library_id)
          controller_save_record(@library_comment)
        end

        def update
          @library_comment.comment   = params_root[:comment]
          if params_root[:uses] != nil 
            if params_root[:uses] > (@library_comment.uses || 0)
              @library_comment.uses      = params_root[:uses]
              @library_comment.last_used = Date.today
            end
          end
## TODO: Make sure that we arent adding any tags that aren't already on the library
          tags         = params_root[:all_tags]
          library      = @library_comment.thinkspace_markup_library
          library_tags = library.tag_list

          library.tag(@library_comment, with: tags, on: :tags)

          controller_save_record(@library_comment)
        end

        def destroy
          controller_destroy_record(@library_comment)
        end

      end
    end
  end
end
