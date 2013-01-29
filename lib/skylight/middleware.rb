module Skylight
  class Middleware
    attr_reader :instrumenter

    def self.new(app, instrumenter)
      return app unless instrumenter
      super
    end

    def initialize(app, instrumenter)
      @instrumenter = instrumenter
      @app = app
    end

    def call(env)
      instrumenter.trace("Rack") do
        ActiveSupport::Notifications.instrument("rack.request") do
          @app.call(env)
        end
      end
    end
  end
end
