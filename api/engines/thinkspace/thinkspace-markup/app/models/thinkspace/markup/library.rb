module Thinkspace
  module Markup
    class Library < ActiveRecord::Base



      acts_as_tagger
      acts_as_taggable

      def all_tags; tag_list; end

      totem_associations

   end
 end
end