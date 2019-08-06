module Thinkspace
  module DiagnosticPath
    class PathItem < ActiveRecord::Base
      totem_associations
      has_paper_trail

      def get_parent
        return nil if not parent_id
        self.class.find(parent_id)
      end
      
    end
  end
end
