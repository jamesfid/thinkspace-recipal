module Thinkspace
  module Artifact
    class Bucket < ActiveRecord::Base
      totem_associations

      # ###
      # ### Clone Content.
      # ###

      include ::Totem::Settings.module.thinkspace.deep_clone_helper

      def cyclone(options={})
        self.transaction do
          cloned_content       = clone_self(options)
          clone_save_record(cloned_content)
        end
      end

      # ###
      # ### Delete Ownerable Data.
      # ###

      include ::Totem::Settings.module.thinkspace.delete_ownerable_data_helper

      def ownerable_data_associations; [:thinkspace_artifact_files]; end

    end
  end
end
