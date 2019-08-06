module Totem
  module Test
    class Engine < ::Rails::Engine

      isolate_namespace Totem::Test
      engine_name 'totem_test'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('totem_test',
          platform_name:  'totem',
          platform_path:  'totem',
          platform_scope: 'totem',
        )
      end

    end
  end
end
