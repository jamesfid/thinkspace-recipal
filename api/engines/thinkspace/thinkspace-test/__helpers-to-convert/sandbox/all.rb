module Thinkspace::Test; module Sandbox; module All
extend ActiveSupport::Concern
included do

  include ::Thinkspace::Test::Casespace::All
  include ::Thinkspace::Test::Sandbox::Assert
  include ::Thinkspace::Test::Sandbox::Cache
  include ::Thinkspace::Test::Sandbox::Models
  include ::Thinkspace::Test::Sandbox::Ownerables

  include ::Thinkspace::Test::Sandbox::Route::Controller

end; end; end; end
