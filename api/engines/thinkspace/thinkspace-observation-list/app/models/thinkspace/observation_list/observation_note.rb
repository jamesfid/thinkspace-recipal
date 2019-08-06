module Thinkspace
  module ObservationList
    class ObservationNote < ActiveRecord::Base
      totem_associations
      has_paper_trail
      validates_presence_of :thinkspace_observation_list_observation
    end
  end
end
