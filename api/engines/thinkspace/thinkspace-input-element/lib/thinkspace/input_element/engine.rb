module Thinkspace
  module InputElement
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::InputElement
      engine_name 'thinkspace_input_element'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_input_element',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'helper_embeds',
        )
      end

    end
  end
end