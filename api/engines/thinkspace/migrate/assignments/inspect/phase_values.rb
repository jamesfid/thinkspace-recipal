require File.expand_path('../../helpers/require_all', __FILE__)
require File.expand_path('../node_values_helper', __FILE__)
module Thinkspace; module Migrate; module Assignments; module Inspect
  class PhaseValues

    include Helpers::Parse
    include Helpers::Node
    include NodeValuesHelper

    attr_reader :process_ids

    def process(args=nil)
      # @process_ids    = ['3','4','5','6']
      set_root_path(args)
      get_assignment_nodes.each do |node|
        id = get_node_id(node)
        next if process_ids.present? && !process_ids.include?(id)
        set_current_assignment_path(id)
        get_assignment_phase_nodes.each do |node|
          collect_node_values(node)
        end
      end
      print_collected_node_values('Phases count')
    end

  end # class

end; end; end; end
