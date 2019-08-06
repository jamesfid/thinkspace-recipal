module Thinkspace
  module DiagnosticPath
    class Path < ActiveRecord::Base

      def has_path_items(scope); self.thinkspace_diagnostic_path_path_items.where(ownerable: scope.current_user).exists?; end
      totem_associations

      # ###
      # ### Clone Path.
      # ###
      include ::Totem::Settings.module.thinkspace.deep_clone_helper

      def cyclone(options={})
        self.transaction do
          cloned_path = clone_self(options)
          clone_save_record(cloned_path)
        end
      end

      # ###
      # ### Delete Ownerable Data.
      # ###

      include ::Totem::Settings.module.thinkspace.delete_ownerable_data_helper

      def ownerable_data_associations; [:thinkspace_diagnostic_path_path_items]; end

    end
  end
end
