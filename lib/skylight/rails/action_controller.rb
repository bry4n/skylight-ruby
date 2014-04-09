module Skylight
  module ActionController
    def skip_skylight_instrument(*actions)
      return unless skylight_instrument
      actions.each do |action|
        controller_action = "#{self.to_s}##{action.to_s}"
        unless skylight_exclusion_exists?(controller_action)
          skylight_exclusions << controller_action
        end
      end
    end

    def skylight_instrument
      @instrument ||= Skylight::Instrumenter.instance
    end

    def skylight_config
      skylight_instrument.config.rails_config.skylight
    end

    def skylight_exclusions
      skylight_config.exclusions
    end

    def skylight_exclusion_exists?(name)
      skylight_exclusions.include?(name)
    end

  end
end

if defined?(Rails)
  ActionController::Base.send(:extend, Skylight::ActionController)
end
