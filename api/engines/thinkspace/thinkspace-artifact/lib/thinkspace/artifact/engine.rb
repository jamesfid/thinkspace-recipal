module Thinkspace
  module Artifact
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Artifact
      engine_name 'thinkspace_artifact'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_artifact',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'tools',
        )
      end

    end
  end
end