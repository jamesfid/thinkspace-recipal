module Thinkspace
  module Simulation
    class Simulation < ActiveRecord::Base
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

    end
  end
end