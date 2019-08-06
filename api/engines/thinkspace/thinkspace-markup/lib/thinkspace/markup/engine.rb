module Thinkspace
  module Markup
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Markup
      engine_name 'thinkspace_markup'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_markup',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'markup',
        )
      end

    end
  end
end