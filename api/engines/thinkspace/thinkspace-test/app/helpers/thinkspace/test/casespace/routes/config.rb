module Cnc::Test; module Casespace; module Routes; class Config < ::Totem::Test::Routes::Config

  include ::Thinkspace::Test::Common::Models

  def route_class; ::Thinkspace::Test::Routes::Route; end

end; end; end; end
