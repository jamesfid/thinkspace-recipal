module Thinkspace
  module Simulation
    module Api
      class SimulationsController < Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options
        
        def index
          controller_render(@simulations)
        end

        def show
          controller_render(@simulation)
        end
      end
    end
  end
end