module Thinkspace
  module Html
    class Content < ActiveRecord::Base        
      totem_associations

      # ###
      # ### Componentable.
      # ###

      def self.create_componentable(authable)
        self.create(authable: authable)
      end

      # ###
      # ### Clone Content.
      # ###

      include ::Totem::Settings.module.thinkspace.deep_clone_helper

      def cyclone(options={})
        self.transaction do
          include_associations = [:thinkspace_input_element_elements]
          cloned_content       = clone_self(options, include_associations)
          clone_save_record(cloned_content)
        end
      end

      # ###
      # ### Delete Ownerable Data.
      # ###

      def delete_all_ownerable_data!
        self.transaction do
          self.thinkspace_input_element_elements.each do |element|
            element.delete_all_ownerable_data!
          end
        end
      end

      def delete_ownerable_data(ownerables)
        self.transaction do
          self.thinkspace_input_element_elements.each do |element|
            element.delete_ownerable_data(ownerables)
          end
        end
      end

    end
  end
end
