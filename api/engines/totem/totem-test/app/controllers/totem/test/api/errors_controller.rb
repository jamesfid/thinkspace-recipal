module Totem; module Test; module Api
class ErrorsController < Totem::Settings.class.thinkspace.authorization_api_controller

  def access_denied
    can_access?
    cancan_access_denied('I am the access denied message.', user_message: 'I am the "user message" for access deined.')
  end

  def not_found
    can_access?
    session_user_model_class.find(123456789)
  end

  def server
    can_access?
    raise 'Test server error.'
  end

  private

  def platform; @platform ||= (::Totem::Settings.registered.platforms - ['totem']).first; end

  def session_user_model_class;        @user_model_class        ||= ::Totem::Settings.authentication.model_class(platform, :user_model); end
  def session_api_session_model_class; @api_session_model_class ||= ::Totem::Settings.authentication.model_class(platform, :api_session_model); end

  def can_access?
    unless ::Rails.env.development?
      cancan_access_denied('Access Denied.  Must be run in development environment.')
    end
  end

  def cancan_access_denied(message, options={})
    subject = options.delete(:subject) || self.class.name
    action  = options.delete(:action)  || action_name.to_sym
    raise_access_denied_exception(message, action, subject, options)
  end

end; end; end; end
