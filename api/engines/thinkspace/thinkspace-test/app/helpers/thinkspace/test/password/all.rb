module Thinkspace::Test; module Password; module All
extend ActiveSupport::Concern
included do
  def sign_in_error;   ::Totem::Authentication::Session::SessionPasswordStrengthError; end
  def sign_in_success; ::Totem::Core::Oauth::ConnectionRefused; end
  def tester;          ::Totem::Authentication::Session::Controllers::Password; end

  def password_test(password);  tester.password_test(password); end
  def password_score(password); tester.score(password); end

  def get_valid_password;   'aB@def$1x#'; end
  def get_invalid_password; '12345678'; end

  def user_name;  "password_strength_" + self.name.gsub(/\W/, '_'); end
  def user_email; "#{user_name}@sixthedge.com"; end

  def create_user
    ::Thinkspace::Common::User.create(first_name: user_name + '_first', last_name: user_name + '_last', email: user_email)
  end

  def assert_valid(password)
    assert_equal true, tester.valid?(password), "password #{password.inspect} should be valid (score=#{tester.score(password)})"
  end

  def assert_invalid(password)
    assert_equal false, tester.valid?(password), "password #{password.inspect} should be invalid (score=#{tester.score(password)})"
  end

  # ### If successfully passes the password strength validation, will attempt a request to totem-oauth.
  # ### Therefore, a success will raise a totem-oauth ConnectionRefused error (e.g. do not start totem-outh for the tests).
  def assert_sign_in_success
    @controller.params = params
    assert_raise(sign_in_success) {@controller.sign_in}
  end

  def assert_sign_in_error
    @controller.params = params
    assert_raise(sign_in_error) {@controller.sign_in}
  end

 end; end; end; end
