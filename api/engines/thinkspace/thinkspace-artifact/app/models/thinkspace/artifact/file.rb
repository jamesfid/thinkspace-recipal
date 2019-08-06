module Thinkspace
  module Artifact
    class File < ActiveRecord::Base
      has_attached_file :attachment,
        path: ":artifact_path/:basename.:extension"

      do_not_validate_attachment_file_type :attachment
      #validates_attachment_content_type :attachment, content_type: %w(image/jpeg image/jpg image/png image/gif)

      def title
        attachment_file_name
      end

      def content_type
        attachment_content_type
      end

      def size
        attachment_file_size
      end

      def url
        attachment.url
      end

      def updateable(scope)
        current_user = scope.current_user
        return false unless current_user
        return true if current_user == ownerable
        teams        = Thinkspace::Team::Team.scope_by_users(current_user)
        return true if teams.include?(ownerable)
        current_ability = scope.current_ability
        bucket          = thinkspace_artifact_bucket
        return false unless current_ability && bucket
        return true if current_ability.can?(:update, bucket.authable)
        false
      end

      # At bottom because it will throw a WARNING otherwise because they above methods haven't been added yet.
      totem_associations
    end
  end
end
