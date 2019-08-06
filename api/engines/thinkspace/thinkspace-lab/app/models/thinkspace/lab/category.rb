module Thinkspace
  module Lab
    class Category < ActiveRecord::Base        
      validates :title, presence: true, uniqueness: {scope: [:thinkspace_lab_chart]}
      totem_associations

      def observation_keys
        columns = (self.value || Hash.new)['columns'] || Array.new
        columns = columns.select {|hash| hash['observation'].present?}
        columns.collect {|hash| hash['observation']}
      end

    end
  end
end
