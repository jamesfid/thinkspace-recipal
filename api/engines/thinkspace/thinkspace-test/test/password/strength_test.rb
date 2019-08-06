require 'password/test_helper'

module Test; module Password; class Strength < ActiveSupport::TestCase
  include ::Thinkspace::Test::Password::All

  describe 'invalid passwords' do
    it 'by length' do
      password = '!wY#2+$'
      assert password_score(password) == 4, "short password (<8 characters) should be strong" # ensure will pass the score test
      assert_invalid(password) # should be invalid due to length < 8
    end
    it 'by score' do
      assert_invalid('password')
      assert_invalid('p@ssw0rd')
      assert_invalid('P@ssW0rd')
      assert_invalid('x@$$W0rd1')
      assert_invalid(get_invalid_password)
    end
  end

  describe 'valid passwords' do
    it 'by score' do
      assert_valid('!aZ#2fx#')
      assert_valid('aB**def$1#')
      assert_valid(get_valid_password)
      assert_valid('1#A' + ('a' * 50) + '$9') # really long password
    end
  end

end; end; end
