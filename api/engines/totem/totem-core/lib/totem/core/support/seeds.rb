module Totem
  module Core
    module Support
        class Seeds

        attr_reader :totem_settings

        def initialize(env)
          @totem_settings = env
        end

        # define seed.
        def seed; self; end

        # instance of seed loader
        def loader(*args)
          class_name = 'Totem::Seed::Loader'
          klass      = class_name.safe_constantize
          error "#{class_name.inspect} cannot be constantized." if klass.blank?
          klass.new(*args)
        end

        private

        include Shared

      end
    end
  end
end
