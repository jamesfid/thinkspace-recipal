module Thinkspace
  module IndentedList
    class List < ActiveRecord::Base

      totem_associations

      def expert?; self.expert; end

      def get_settings; self.settings || Hash.new; end

      def expert_list_list_id; get_settings['list_id']; end

      # ###
      # ### Clone Path.
      # ###

      include ::Totem::Settings.module.thinkspace.deep_clone_helper

      def cyclone(options={})
        self.transaction do
          if expert?
            list_id = expert_list_list_id
            list    = Thinkspace::IndentedList::List.find_by(id: list_id)
            raise_clone_exception "List [#{id}] does not exist, cannot continue." unless list.present?
            cloned_expert_list = get_cloned_record_from_dictionary(list, get_clone_dictionary(options))
            if cloned_expert_list.present?
              include_associations            = [:thinkspace_indented_list_expert_responses]
              cloned_list                     = clone_self(options, include_associations)
              cloned_list.settings['list_id'] = cloned_expert_list.id
            else
              # Do not do any association or setting of list_id if the cloned_expert_list is not present.
              # => This occurs when the clone originates from a phase and not a full case clone.
              cloned_list = clone_self(options)
            end
            clone_save_record(cloned_list)
          else
            cloned_list = clone_self(options)
            clone_save_record(cloned_list)
          end
        end
      end

      # ###
      # ### Delete Ownerable Data.
      # ###

      include ::Totem::Settings.module.thinkspace.delete_ownerable_data_helper

      def ownerable_data_associations; [:thinkspace_indented_list_responses]; end

    end
  end
end
