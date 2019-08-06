module Thinkspace
  module ObservationList
    module Api
      module Admin
        class GroupsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class

          def create
            type = params_root[:groupable_type]
            id   = params_root[:groupable_id]
            access_denied('Groupable id is not present, cannot proceed.') unless id.present?
            access_denied('Groupable type is not present, cannot proceed.') unless type.present?
            klass = type.classify.safe_constantize
            access_denied("No related class found for groupable type: [#{type}].") unless klass.present?
            groupable = klass.find_by(id: id)
            access_denied("No groupable found for type/id: [#{type}]/#{id}]") unless groupable.present?
            authorize!(:update, groupable)
            @group.groupable = groupable
            @group.title = params_root[:title] || "#{Time.now} - New Group"
            controller_save_record(@group)
          end

          private

          def access_denied(message, action=:create, records=nil)
            raise_access_denied_exception(message, action, records)
          end

        end
      end
    end
  end
end
