module Thinkspace
  module ObservationList
    class Group < ActiveRecord::Base
      totem_associations
      validates_presence_of :groupable
    end
  end
end