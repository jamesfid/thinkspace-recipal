module Thinkspace
  module ObservationList
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::ObservationList
      engine_name 'thinkspace_observation_list'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_observation_list',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'helpers',
        )
      end

    end
  end
end