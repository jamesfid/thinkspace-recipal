require File.expand_path('../../helpers/require_all', __FILE__)
require File.expand_path('../node_values_helper', __FILE__)
module Thinkspace; module Migrate; module Assignments; module Inspect
  class LabtestValues

    include Helpers::Parse
    include Helpers::Node
    include NodeValuesHelper

    attr_reader :process_ids

    def process(args=nil)
      title = 'Lab test count'
      set_root_path(args)
      get_assignment_nodes.each do |node|
        id = get_node_id(node)
        set_current_assignment_path(id)
        get_assignment_phase_nodes.each do |node|
          @current_phase_node = node
          next unless get_phase_type == 'labtest'
          id          = get_phase_id
          phase_node  = get_phase_node(id)
          phase_node.css('labtest').each do |node|
            # next unless get_labtest_type(node) == 'title'
            # next unless get_labtest_type(node) == 'result'
            # next unless get_labtest_type(node) == 'header'
            # next unless get_labtest_type(node) == 'adjustedResult'
            next unless get_labtest_type(node) == 'observation'
            collect_node_values(node)
          end
        end
      end
      print_collected_node_values(title)
      # print_collected_node_values(title, only: [:type])
      # print_collected_node_values(title, except: [:result])
      # print_collected_node_values(title, only: [:result])
    end

    def get_labtest_type(node)
      val = node.css('type')
      val.present? ? val.text : nil
    end


  end # class

end; end; end; end
