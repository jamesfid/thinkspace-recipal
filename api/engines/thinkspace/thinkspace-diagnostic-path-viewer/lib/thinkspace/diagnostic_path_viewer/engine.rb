module Thinkspace
  module DiagnosticPathViewer
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::DiagnosticPathViewer
      engine_name 'thinkspace_diagnostic_path_viewer'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_diagnostic_path_viewer',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'tools',
        )
      end

    end
  end
end