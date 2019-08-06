module Thinkspace
  module Simulation
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Simulation
      engine_name 'thinkspace_simulation'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_simulation',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'simulation',
        )
      end

    end
  end
end