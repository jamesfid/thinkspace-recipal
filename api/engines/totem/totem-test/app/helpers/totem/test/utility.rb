module Totem::Test::Utility
extend ActiveSupport::Concern

  module UtilityHelpers

    def timestamp; @timestamp ||= Time.now; end

    def get_let_value(name);       (self.respond_to?(name.to_sym) && self.send(name)) || nil; end
    def get_let_value_array(name); [get_let_value(name)].flatten.compact; end

    # def get_platform_name; @_platform_names ||= [::Totem::Settings.registered.platform_names.last]; end
    def get_platform_name; @_platform_names ||= ::Totem::Settings.registered.platform_names.last; end

    def get_platform_class_name(mods=nil)
      class_name = get_platform_name.camelize
      mods.blank? ? class_name : "#{class_name}::#{mods}"
    end

    def constantize_platform_class(mods=nil); constantize_class(get_platform_class_name(mods)); end

    def constantize_class(class_name)
      klass = class_name.safe_constantize
      error "Class name #{class_name.inspect} could not be constantized." if klass.blank?
      klass
    end

    def color(*args); (@console_print_class ||= ::Totem::Core::Console::Print.new).color(*args); end

    def error(message)
      raise color("#{self.class.name}: #{message}", :red, :bold)
    end

  end # Utility

  class_methods do
    include UtilityHelpers
  end

  included do
    include UtilityHelpers
  end

end
