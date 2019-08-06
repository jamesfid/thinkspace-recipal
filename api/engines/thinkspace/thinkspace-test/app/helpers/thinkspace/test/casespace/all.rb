module Thinkspace::Test; module Casespace; module All
extend ActiveSupport::Concern
included do

  include ::Totem::Test::All

  include ::Thinkspace::Test::Casespace::Json
  include ::Thinkspace::Test::Casespace::Models
  include ::Thinkspace::Test::Casespace::Routes

end; end; end; end
