module Thinkspace
  module ObservationList
    class List < ActiveRecord::Base
      totem_associations

      # ###
      # ### Clone List.
      # ###

      include ::Totem::Settings.module.thinkspace.deep_clone_helper

      def cyclone(options={})
        self.transaction do
          groups = self.thinkspace_observation_list_groups
          
          if groups.blank?
            cloned_list = clone_self(options)
            clone_save_record(cloned_list)
          else
            groupable = groups.first.groupable
            raise_clone_exception "Observation list id #{self.id} group id #{group.id} groupable is blank."  if groupable.blank?
            cloned_groupable = get_cloned_record_from_dictionary(groupable, get_clone_dictionary(options))
            if cloned_groupable.present?
              include_associations = {thinkspace_observation_list_group_lists: {thinkspace_observation_list_group: [:groupable]}}
            elsif options[:is_template]
              # Do not include any group lists, as it comes from a domain-esque template.
              include_associations = nil
            else
              include_associations = [:thinkspace_observation_list_group_lists]
            end
            cloned_list = clone_self(options, include_associations)
            clone_save_record(cloned_list)
          end

        end
      end

      # ###
      # ### Delete Ownerable Data.
      # ###

      include ::Totem::Settings.module.thinkspace.delete_ownerable_data_helper

      def ownerable_data_associations; [:thinkspace_observation_list_observations]; end

    end
  end
end
