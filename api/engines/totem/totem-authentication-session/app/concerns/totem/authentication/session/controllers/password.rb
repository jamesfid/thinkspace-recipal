module Totem
  module Authentication
    module Session
      module Controllers
        module Password

          PASSWORD_TESTER = Zxcvbn::Tester.new.freeze

          def self.valid?(password)
            return false if password.blank?
            return false unless password.is_a?(String)
            return false unless password.length > 7
            score(password) > 2
          end

          # Score is an Integer value in range of 0 to 4 with:
          #   0 = Worst
          #   1 = Bad
          #   2 = Weak
          #   3 = Good
          #   4 = Strong
          def self.score(password)
            password_test(password).score
          end

          def self.password_test(password)
            PASSWORD_TESTER.test(password)
          end

        end

        Password.freeze

      end
    end
  end
end
