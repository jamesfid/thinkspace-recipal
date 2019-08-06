module Thinkspace
  module Artifact
    module Api
      module Admin
        class BucketsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class

          def update
            authorize!(:update, @bucket.authable)
            @bucket.instructions = params_root[:instructions]
            controller_save_record(@bucket)
          end

        end
      end
    end
  end
end
