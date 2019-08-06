module Totem::Test; module Ability; module Test; module Cannot
  extend ActiveSupport::Concern
  included do

  def self.run_ability_cannot_tests(models, actions, users)
    models.each do |model|
      actions.each do |action|
        users.each do |user|
          describe 'ability'  do
            it "..#{get_username(user)}..cannot..#{action}..#{model.title}.." do
              assert_cannot(user, model, action)
            end
          end
        end
      end
    end
  end

end; end; end; end; end
