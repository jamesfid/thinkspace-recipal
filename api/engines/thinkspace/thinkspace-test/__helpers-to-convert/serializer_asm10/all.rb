module Thinkspace::Test; module SerializerAsm10; module All
extend ActiveSupport::Concern
included do

  include ::Thinkspace::Test::Casespace::All
  include ::Thinkspace::Test::SerializerAsm10::Assert
  include ::Thinkspace::Test::SerializerAsm10::Models
  include ::Thinkspace::Test::SerializerAsm10::Ownerables
  include ::Thinkspace::Test::SerializerAsm10::Ability
  include ::Thinkspace::Test::SerializerAsm10::Cache

  include ::Thinkspace::Test::SerializerAsm10::Route::Controller

end; end; end; end
