module Totem
  module Seed
    class Engine < ::Rails::Engine

      isolate_namespace Totem::Seed
      engine_name 'totem_seed'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('totem_seed',
          platform_name:  'totem',
          platform_path:  'totem',
          platform_scope: 'totem',
        )
      end

    end
  end
end
