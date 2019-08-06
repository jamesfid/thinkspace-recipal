module Thinkspace
  module ObservationList
    class Observation < ActiveRecord::Base
      totem_associations
      has_paper_trail
      validates_presence_of :thinkspace_common_user, :thinkspace_observation_list_list
      validates_presence_of :ownerable

      before_destroy :migrate_data_to_path_items

      def migrate_data_to_path_items
        path_items = Thinkspace::DiagnosticPath::PathItem.where(path_itemable: self)
        path_items.each do |path_item|
          path_item.path_itemable = nil
          path_item.description   = self.value
          category                = self.thinkspace_observation_list_list.category
          path_item.category      = category if category.present?
          path_item.save
        end
      end

    end
  end
end
