module Thinkspace
  module Markup
    class Discussion < ActiveRecord::Base

      def updateable(scope)
        current_user = scope.current_user
        return true if current_user == creatorable
        teams        = Thinkspace::Team::Team.scope_by_users(current_user)
        return true if teams.include?(creatorable)
        false
      end

      totem_associations

   end
 end
end