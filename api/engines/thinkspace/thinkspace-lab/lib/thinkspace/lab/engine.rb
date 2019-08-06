module Thinkspace
  module Lab
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Lab
      engine_name 'thinkspace_lab'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_lab',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'tools',
        )
      end

    end
  end
end