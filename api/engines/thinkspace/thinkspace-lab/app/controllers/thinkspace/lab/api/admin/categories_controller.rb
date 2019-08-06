module Thinkspace
  module Lab
    module Api
      module Admin
        class CategoriesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class

          def create
            chart_id = params_association_id(:chart_id)
            access_denied "Lab category create chart id is blank."  if chart_id.blank?
            chart = Thinkspace::Lab::Chart.find_by(id: chart_id)
            access_denied "Lab category create chart [id: #{chart_id}] not found."  if chart.blank?
            authorize!(:update, chart.authable)
            @category.chart_id = chart_id
            set_category_values_from_params
            controller_save_record(@category)
          end

          def update
            authorize!(:update, @category.authable)
            set_category_values_from_params
            controller_save_record(@category)
          end

          def destroy
            authorize!(:update, @category.authable)
            controller_destroy_record(@category)
          end

          def result_positions
            authorize!(:update, @category.authable)
            positions = [params[:result_positions]].flatten.compact
            results   = @category.thinkspace_lab_results
            @category.transaction do
              begin
                positions.each do |hash|
                  id       = hash[:id]
                  position = hash[:position]
                  next if id.blank? or position.blank?
                  result = results.find {|c| c.id == id.to_i}
                  next if result.blank?
                  result.position = position
                  raise PositionError, "Error saving lab result [id: #{id}] for category [id: #{@category.id}] position change."  unless result.save
                end
              rescue PositionError => e
                access_denied e.message
              end
            end
            controller_render_no_content
          end

          private

          def set_category_values_from_params
            @category.title    = params_root[:title]
            @category.position = params_root[:position]
            @category.value    = params_root[:value]
            serializer_options.remove_all_except(:thinkspace_lab_chart, :thinkspace_lab_results)
          end

          def access_denied(message, user_message=nil)
            raise_access_denied_exception(message, self.action_name, @category, user_message: user_message)
          end

          class PositionError < StandardError; end

        end
      end
    end
  end
end
