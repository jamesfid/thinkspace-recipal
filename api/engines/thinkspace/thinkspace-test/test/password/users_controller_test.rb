require 'password/test_helper'
generate_model_serializers

module Test; module Password; class UsersController < ActionController::TestCase
  include ::Thinkspace::Test::Password::All

  describe ::Thinkspace::Common::Api::UsersController do
    let (:params) { {identification: user_email, password: get_invalid_password} }
    it 'valid with existing user' do
      create_user
      assert_sign_in_success
    end
    it 'invalid with new user' do
      assert_sign_in_error
    end
  end

  describe ::Thinkspace::Common::Api::UsersController do
    let (:params) { {identification: user_email, password: get_valid_password} }
    it 'valid with new user' do
      assert_sign_in_success
    end
  end

end; end; end
