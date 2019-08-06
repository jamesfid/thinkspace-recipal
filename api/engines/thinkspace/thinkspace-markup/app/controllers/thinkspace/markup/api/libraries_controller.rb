module Thinkspace
  module Markup
    module Api
      class LibrariesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        #totem_action_authorize! only: [:create, :destroy, :update], ownerable_ability_action: :view, module: :action_authorize_markup

        def select
          @libraries = @libraries.where(id: params[:ids])
          serializer_options.include_association(:thinkspace_markup_library_comments)
          controller_render(@libraries)
        end

        def show
          serializer_options.include_association(:thinkspace_markup_library_comments)
          controller_render(@library)
        end

        def create
          @library.user_id       = current_user.id
          controller_save_record(@library)
        end

        def update
          controller_save_record(@library)
        end

        def fetch
          # Get the current_user's library.
          @library = Thinkspace::Markup::Library.find_or_create_by(user_id: current_user.id)
          controller_render(@library)
        end

        def add_tag
          @library = Thinkspace::Markup::Library.find(params[:id])

          tag = params[:tag_name]

          @library.tag_list.add(tag)

          controller_save_record(@library)
        end

        def add_comment_tag
          @library = Thinkspace::Markup::Library.find(params[:id])
          library_comment = Thinkspace::Markup::LibraryComment.find(params[:comment_id])

          all_tags = params[:all_tags]

          @library.tag(library_comment, with: all_tags, on: :tags)
          controller_save_record(library_comment)
        end

        def remove_comment_tag
          @library        = Thinkspace::Markup::Library.find(params[:id])
          library_comment = Thinkspace::Markup::LibraryComment.find(params[:comment_id])

          all_tags = params[:all_tags]

          @library.tag(library_comment, with: all_tags, on: :tags)
          controller_save_record(@library)
        end

        def destroy
          controller_destroy_record(@library)
        end

      end
    end
  end
end