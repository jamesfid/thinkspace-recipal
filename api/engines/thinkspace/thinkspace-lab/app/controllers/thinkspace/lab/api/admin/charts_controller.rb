module Thinkspace
  module Lab
    module Api
      module Admin
        class ChartsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class

          def load
            authorize!(:update, @chart.authable)
            serializer_options.remove_association  :ownerable
            serializer_options.remove_association  :authable
            serializer_options.remove_association  :thinkspace_lab_observations
            serializer_options.remove_association  :thinkspace_lab_chart, scope: :thinkspace_lab_results
            serializer_options.include_association :thinkspace_lab_categories
            serializer_options.include_association :thinkspace_lab_results
            serializer_options.except_attributes   :values, scope: :thinkspace_lab_results
            serializer_options.add_attributes      :value, :metadata, scope: :thinkspace_lab_results
            controller_render(@chart)
          end

          def category_positions
            authorize!(:update, @chart.authable)
            positions  = [params[:category_positions]].flatten.compact
            categories = @chart.thinkspace_lab_categories
            @chart.transaction do
              begin
                positions.each do |hash|
                  id       = hash[:id]
                  position = hash[:position]
                  next if id.blank? or position.blank?
                  category = categories.find {|c| c.id == id.to_i}
                  next if category.blank?
                  category.position = position
                  raise PositionError, "Error saving lab category [id: #{id}] for chart [id: #{@chart.id}] position change."  unless category.save
                end
              rescue PositionError => e
                access_denied e.message
              end
            end
            controller_render_no_content
          end

          private

          class PositionError < StandardError; end

        end
      end
    end
  end
end
