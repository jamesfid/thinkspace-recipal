module Thinkspace::Test; module Clone; module All
extend ActiveSupport::Concern
included do

  include ::Thinkspace::Test::Casespace::All
  include ::Thinkspace::Test::Clone::Assert
  include ::Thinkspace::Test::Clone::Clone
  include ::Thinkspace::Test::Clone::Dictionary

end; end; end; end
