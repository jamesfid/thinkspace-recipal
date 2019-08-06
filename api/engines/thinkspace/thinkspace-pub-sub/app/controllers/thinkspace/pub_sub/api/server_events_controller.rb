module Thinkspace
  module PubSub
    module Api
      class ServerEventsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class

        def load_messages
          validate_load_message_params
          validate_rooms(get_rooms)
          server_events = controller_model_class.scope_messages(get_rooms, get_start_time, get_end_time).order(created_at: :desc)
          serializer_options.remove_all
          hash = controller_as_json(server_events)
          controller_render_json({messages: hash[controller_plural_path]})
        end

        private

        include PubSub::AuthorizeHelpers

        def get_params; params[action_name] || Hash.new; end

        def get_room_type; get_params[:room_type]; end
        def get_rooms;     @server_event_rooms ||= [get_params[:rooms]].flatten.compact; end

        # TODO: Add team based validation rules.
        # TODO: Check for assignment & phase due_at? - Use taa?
        def validate_load_message_params
          access_denied "Must supply rooms to load messages."  if get_rooms.blank?
        end

        def get_start_time
          from_time = get_params[:from_time]
          if from_time.blank?
            if get_params[:from_last_login].present?
              api_session = read_api_session(current_user)
              access_denied "API session is blank." if api_session.blank?
              start_time = api_session.created_at
            else
              ndays      = get_params[:from_days] || 1
              start_time = Time.now.utc - ndays.to_i.days
            end
          else
            start_time = Time.parse(from_time).utc rescue nil
            access_denied "Params start time #{from_time.inspect} is an invalid time format." if start_time.blank?
          end
          start_time
        end

        def get_end_time
          to_time = get_params[:to_time]
          return nil if to_time.blank?
          end_time = Time.parse(to_time).utc rescue nil
          access_denied "Params end time #{to_time.inspect} is an invalid time format." if end_time.blank?
          end_time
        end

        def access_denied(message, user_message='')
          action = (self.action_name || '').to_sym
          model  = @server_event || controller_model_class
          raise_access_denied_exception(message, action, model, user_message: user_message)
        end

      end
    end
  end
end
