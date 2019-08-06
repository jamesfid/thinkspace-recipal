module Thinkspace
  module DiagnosticPathViewer
    class Viewer < ActiveRecord::Base
      totem_associations

      private

      # ###
      # ### Clone Viewer.
      # ###

      include ::Totem::Settings.module.thinkspace.deep_clone_helper

      def cyclone(options={})
        self.transaction do
          cloned_viewer = clone_self(options)

          path = self.thinkspace_diagnostic_path_path
          if path.present?
            dictionary  = get_clone_dictionary(options)
            cloned_path = get_cloned_record_from_dictionary(path, dictionary)
          end

          cloned_viewer.path_id = cloned_path.present? ? cloned_path.id : nil
          clone_save_record(cloned_viewer)

          if cloned_path.present? && is_full_clone?(options)
            ownerable = self.ownerable
            if ownerable.present?
              path_items    = path.thinkspace_diagnostic_path_path_items.where(ownerable: ownerable)
              include_assoc = [:thinkspace_diagnostic_path_path, {path_itemable: :thinkspace_observation_list_list}]
              path_items.each do |path_item|
                cloned_path_item = clone_record(path_item, options, include_assoc, :parent_id)
                clone_save_record(cloned_path_item)
              end
            end
          end

          cloned_viewer
        end
      end

      def clone_last; true; end

    end
  end
end
