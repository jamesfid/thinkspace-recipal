module Thinkspace
  module ObservationList
    class GroupList < ActiveRecord::Base
      totem_associations
      validates_presence_of :thinkspace_observation_list_group, :thinkspace_observation_list_list
    end
  end
end