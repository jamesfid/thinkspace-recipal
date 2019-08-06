module Thinkspace
  module Lab
    class Chart < ActiveRecord::Base
      totem_associations

      validates :title, presence: true, uniqueness: {scope: [:authable]}

      # ###
      # ### Clone Chart.
      # ###

      include ::Totem::Settings.module.thinkspace.deep_clone_helper

      def cyclone(options={})
        self.transaction do
          clone_associations = {thinkspace_lab_categories: [:thinkspace_lab_results]}
          cloned_chart       = clone_self(options, clone_associations)
          clone_save_record(cloned_chart)
        end
      end

      # ###
      # ### Delete Ownerable Data.
      # ###

      def delete_all_ownerable_data!
        self.transaction do
          self.thinkspace_lab_categories.each do |category|
            category.thinkspace_lab_results.each do |result|
              result.delete_all_ownerable_data!
            end
          end
        end
      end

      def delete_ownerable_data(ownerables)
        self.transaction do
          self.thinkspace_lab_categories.each do |category|
            category.thinkspace_lab_results.each do |result|
              result.delete_ownerable_data(ownerables)
            end
          end
        end
      end

    end
  end
end
