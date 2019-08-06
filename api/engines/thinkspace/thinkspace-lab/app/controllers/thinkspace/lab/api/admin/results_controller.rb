module Thinkspace
  module Lab
    module Api
      module Admin
        class ResultsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class

          def create
            category_id = params_association_id(:category_id)
            access_denied "Lab result create category id is blank."  if category_id.blank?
            category = Thinkspace::Lab::Category.find_by(id: category_id)
            access_denied "Lab result create category [id: #{category_id}] not found."  if category.blank?
            authorize!(:update, category.authable)
            @result.category_id = category.id
            set_result_values_from_params
            controller_save_record(@result)
          end

          def update
            authorize!(:update, @result.authable)
            set_result_values_from_params
            controller_save_record(@result)
          end

          def destroy
            authorize!(:update, @result.authable)
            controller_destroy_record(@result)
          end

          private

          def set_result_values_from_params
            @result.title    = params_root[:title]
            @result.position = params_root[:position]
            @result.value    = params_root[:value]     unless params_root[:value]    == @result.value
            @result.metadata = params_root[:metadata]  unless params_root[:metadata] == @result.metadata
            serializer_options.except_attributes :values, scope: :root
            serializer_options.add_attributes    :value, :metadata
          end

          def access_denied(message, user_message=nil)
            raise_access_denied_exception(message, self.action_name, @result, user_message: user_message)
          end

        end
      end
    end
  end
end
