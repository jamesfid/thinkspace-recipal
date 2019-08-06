module Thinkspace
  module Reporter
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Reporter
      engine_name 'thinkspace_reporter'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_reporter',
          platform_type:  'thinkspace',
          platform_name:  'thinkspace',
          platform_path:  'thinkspace',
          platform_scope: 'thinkspace',
          platform_sub_type: 'reporter'
        )
      end

    end
  end
end