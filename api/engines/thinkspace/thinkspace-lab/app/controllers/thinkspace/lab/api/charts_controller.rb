module Thinkspace
  module Lab
    module Api
      class ChartsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options

        def show
          controller_render(@chart)
        end

        def view
          controller_render_view(@chart)
        end

        def select
          controller_render(@charts)
        end

        def update
          begin
            @chart.transaction do
              html = params_root[:html_content]
              hash = validate_html_content(html)
              process_element_changes(hash[:create], hash[:delete])
              @chart.html_content = html
              controller_save_record(@chart)
            end
          rescue ProcessInputElementError
            controller_render_error(@chart)
          end
        end

        private

      end
    end
  end
end
