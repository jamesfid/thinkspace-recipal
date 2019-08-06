module Totem::Test; module Ability; module Test; module Can
extend ActiveSupport::Concern
included do

  def self.run_ability_can_tests(models, actions, users)
    models.each do |model|
      actions.each do |action|
        users.each do |user|
          describe 'ability'  do
            it "..#{get_username(user)}..can..#{action}..#{model.title}.." do
              assert_can(user, model, action)
            end
          end
        end
      end
    end
  end

end; end; end; end; end
