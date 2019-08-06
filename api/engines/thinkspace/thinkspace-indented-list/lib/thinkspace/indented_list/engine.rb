module Thinkspace
  module IndentedList
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::IndentedList
      engine_name 'thinkspace_indented_list'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_indented_list',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'tools',
        )
      end

    end
  end
end
