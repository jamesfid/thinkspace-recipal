module Thinkspace
  module IndentedList
    class ExpertResponse < ActiveRecord::Base
      totem_associations
      has_paper_trail

      # ###
      # ### AASM
      # ###

      include AASM
      aasm column: :state do
        state :neutral, initial: true
        state :active
        state :inactive
        event :activate do;   transitions to: :active; end
        event :inactivate do; transitions to: :inactive; end
      end

      # ###
      # ### Scopes.
      # ###

      def self.scope_active; active; end  # acitve = aasm auto-generated scope

      # ###
      # ### Helpers
      # ###
      def inactivate_others
        list = thinkspace_indented_list_list
        return unless list.present?
        ids       = list.thinkspace_indented_list_expert_responses.where.not(id: self.id).pluck(:id)
        responses = Thinkspace::IndentedList::ExpertResponse.where(id: ids)
        responses.each do |response|
          response.state = 'inactive'
          response.save
        end
      end

    end
  end
end
