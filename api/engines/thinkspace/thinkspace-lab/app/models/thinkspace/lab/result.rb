module Thinkspace
  module Lab
    class Result < ActiveRecord::Base
      def values; get_values_hash; end
      totem_associations

      # Generate a 'values' hash. Allows adjusting the hash if needed
      # e.g. include some metadata if want to do client validation, remove some data, etc.
      def get_values_hash
        category       = self.thinkspace_lab_category
        category_value = category.value || Hash.new
        case category_value['component']
        when 'vet_med'
          values     = (self.value || Hash.new).deep_dup
          obs_values = (values['observations'] ||= Hash.new)
          obs_values.deep_merge!(self.metadata || Hash.new)
          values
        else
          self.value
        end
      end

      # ###
      # ### Delete Ownerable Data.
      # ###

      include ::Totem::Settings.module.thinkspace.delete_ownerable_data_helper

      def ownerable_data_associations; [:thinkspace_lab_observations]; end

    end
  end
end
