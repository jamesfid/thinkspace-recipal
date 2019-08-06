require File.expand_path('../../helpers/require_all', __FILE__)
module Thinkspace; module Migrate; module Assignments; module Inspect
  class LabCharts

    include Helpers::Parse
    include Helpers::Node

    attr_reader :process_ids

    def process(args=nil)
      @count         = 0
      @verbose       = true
      @debug         = true
      @process_ids = ['3']
      # @process_ids = ['1', '2', '3']
      set_root_path(args)
      get_assignment_nodes.each do |node|
        id = get_node_id(node)
        next if process_ids.present? && !process_ids.include?(id)
        set_current_assignment_path(id)
        @current_assignment_node = node
        get_assignment_phase_nodes.each do |node|
          @current_phase_node = node
          next unless get_phase_type == 'labtest'
          validate_lab_component
        end
      end
      puts "Labtest count: #{@count}"
    end

    def validate_lab_component
      id          = get_phase_id
      phase_node  = get_phase_node(id)
      chart_nodes = phase_node.css('labtest')
      raise_error 'No lab test chart nodes.'  if chart_nodes.blank?
      title         = 'LAB CHART'
      chart = Helpers::LabChart.new(self, chart_nodes)
      @count += 1
# pp chart.categories
    end

  end # class

end; end; end; end
