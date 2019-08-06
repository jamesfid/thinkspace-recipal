module Thinkspace; module PubSub; module AuthHelpers

  extend ::ActiveSupport::Concern

  class_methods do
    # Capture authentication exceptions and return a pubsub 'can: false' response.
    def session_error_class; Totem::Authentication::Session::SessionError; end
  end

  included do

    # ###
    # ### Authenticate User with Params Token and Email.
    # ###

    rescue_from session_error_class, *session_error_class.descendants do |e|
      render_access_denied e.message || 'session error'
    end

    # Override the totem authentication method and get the token and email from the params (e.g. instead of from http headers).
    def totem_authenticate_user_from_token!; authenticate_user_from_auth_token(get_token, get_email); end

    # ###
    # ###
    # ###

    # TODO: Anyway around not needing this for Totem::Core::Controllers::TotemActionAuthorize::Authorize?
    def controller_model_class_name; current_user.class.name; end

    # ###
    # ### User Data.
    # ###

    def current_user_data
      hash = {
        id:         current_user.id,
        first_name: current_user.first_name,
        last_name:  current_user.last_name,
        username:   current_user.username,
      }
      hash[:superuser] = current_user.superuser?  if current_user.superuser?
      hash
    end

    # ###
    # ### Params Helpers.
    # ###

    def get_auth;  params[:auth] || Hash.new; end
    def get_token; get_auth[:token]; end
    def get_email; get_auth[:email]; end

    def get_room_type; params[:room_type]; end

    def get_rooms
      rooms = params[:rooms]
      return rooms.values if rooms.is_a?(Hash)
      rooms
    end

    # ###
    # ### Access Denied.
    # ###

    class AccessDenied < StandardError; end

    rescue_from AccessDenied do |e|
      render_access_denied e.message
    end

    # Override for totem_action_authorize and return a pubsub 'can: false' response.
    def raise_access_denied_exception(*args)
      options = args.extract_options!
      message = options[:message] || 'no exception message'
      access_denied(message)
    end

    # Raise an exception (captured with rescue_from) to interupt the noraml flow
    # and return a 'can: false' response.
    def access_denied(message); raise AccessDenied, message; end

    def render_access_denied(message); controller_render_json({can: false, message: message}); end

  end

end; end; end
