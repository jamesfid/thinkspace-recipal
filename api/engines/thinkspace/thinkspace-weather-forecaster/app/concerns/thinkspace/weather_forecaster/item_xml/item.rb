module Thinkspace
  module WeatherForecaster
    module ItemXml

      class Item

        attr_reader :response
        attr_reader :processing
        attr_reader :help_tip

        attr_accessor :id
        attr_accessor :title
        attr_accessor :description
        attr_accessor :header
        attr_accessor :content

        include SupportClasses

        def initialize
          @help_tip = Hash.new
        end

        def radio(id);    @response   = RadioResponse.new(id);    end
        def input(id);    @response   = InputResponse.new(id);    end
        def checkbox(id); @response   = CheckboxResponse.new(id); end
        def processor;    @processing = ProcessorItem.new; end

        def add_help_tip_html(tip)
          help_tip[:html] ||= ''
          help_tip[:html] += tip
        end

      end

    end
  end
end

