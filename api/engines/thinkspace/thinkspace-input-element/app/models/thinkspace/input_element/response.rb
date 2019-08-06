module Thinkspace
  module InputElement
    class Response < ActiveRecord::Base
      totem_associations
      has_paper_trail
      validates_presence_of :ownerable
    end
  end
end
