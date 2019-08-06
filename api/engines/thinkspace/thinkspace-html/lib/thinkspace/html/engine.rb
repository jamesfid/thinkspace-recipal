require 'ckeditor'
require 'nokogiri'

module Thinkspace
  module Html
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Html
      engine_name 'thinkspace_html'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_html',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'tools',
        )
      end

    end
  end
end