module Totem::Test; module Ability; module All
extend ActiveSupport::Concern
included do

  include ::Totem::Test::Ability::Assert
  include ::Totem::Test::Ability::Cancan
  include ::Totem::Test::Ability::Dictionary
  include ::Totem::Test::Ability::Rules
  include ::Totem::Test::Ability::Test::Can
  include ::Totem::Test::Ability::Test::Cannot
  include ::Totem::Test::Utility

end; end; end; end
