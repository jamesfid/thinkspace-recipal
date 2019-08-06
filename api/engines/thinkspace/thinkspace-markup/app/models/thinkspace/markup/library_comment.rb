module Thinkspace
  module Markup
    class LibraryComment < ActiveRecord::Base

      acts_as_taggable

      def all_tags; all_tags_list; end

      totem_associations

   end
 end
end