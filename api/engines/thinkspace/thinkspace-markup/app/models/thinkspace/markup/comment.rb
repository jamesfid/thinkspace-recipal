module Thinkspace
  module Markup
    class Comment < ActiveRecord::Base

      def updateable(scope)
        current_user = scope.current_user
        return true if current_user == commenterable
        teams        = Thinkspace::Team::Team.scope_by_users(current_user)
        return true if teams.include?(commenterable)
        false
      end

      def authable; thinkspace_markup_discussion.authable; end

      totem_associations

   end
 end
end