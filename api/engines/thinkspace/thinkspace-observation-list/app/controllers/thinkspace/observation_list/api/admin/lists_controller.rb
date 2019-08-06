module Thinkspace
  module ObservationList
    module Api
      module Admin
        class ListsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class

          before_filter :authorize_authable

          def update
            @list.category = params_root[:category]
            controller_save_record(@list)
          end

          def groups
            groups = @list.thinkspace_observation_list_groups
            controller_render(groups)
          end

          def assignable_groups
            phase      = @list.authable
            assignment = phase.thinkspace_casespace_assignment
            authorize!(:update, assignment)
            groups     = Thinkspace::ObservationList::Group.where(groupable: assignment)
            controller_render(groups)
          end

          def assign_group
            group = get_and_authorize_group_from_params(:assign_group)
            @list.thinkspace_observation_list_groups << group
            controller_render(@list)
          end

          def unassign_group
            group = get_and_authorize_group_from_params(:unassign_group)
            @list.thinkspace_observation_list_groups.delete(group)
            controller_render(@list)
          end

          private

          def get_and_authorize_group_from_params(action)
            group_id = params[:group_id]
            group    = Thinkspace::ObservationList::Group.find_by(id: group_id)
            access_denied("Invalid group id of: [#{group_id}]", action) unless group.present?
            authorize!(:update, group.groupable)
            group
          end

          def authorize_authable
            authorize!(:update, @list.authable)
          end

          def access_denied(message, action=:create, records=nil)
            raise_access_denied_exception(message, action, records)
          end

        end
      end
    end
  end
end
