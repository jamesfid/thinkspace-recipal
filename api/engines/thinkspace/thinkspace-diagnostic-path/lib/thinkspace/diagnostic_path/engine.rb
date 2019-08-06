module Thinkspace
  module DiagnosticPath
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::DiagnosticPath
      engine_name 'thinkspace_diagnostic_path'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_diagnostic_path',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'tools',
        )
      end

    end
  end
end