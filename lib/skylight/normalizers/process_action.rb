module Skylight
  module Normalizers
    class ProcessAction < Normalizer
      register "process_action.action_controller"

      CAT = "app.controller.request".freeze
      PAYLOAD_KEYS = %w[ controller action params format method path ].map(&:to_sym).freeze

      def normalize(trace, name, payload)
        unless excluded?(trace, payload)
          trace.endpoint = controller_action(payload)
          [ CAT, trace.endpoint, nil, normalize_payload(payload) ]
        else
          :skip
        end
      end

    private

      def controller_action(payload)
        "#{payload[:controller]}##{payload[:action]}"
      end

      def normalize_payload(payload)
        normalized = {}

        PAYLOAD_KEYS.each do |key|
          val = payload[key]
          val = val.inspect unless val.is_a?(String) || val.is_a?(Numeric)
          normalized[key] = val
        end

        normalized
      end

      def excluded?(trace, payload)
        debugger
        return false unless rails_config
        name = controller_action(payload)
        exclusions.include?(name)
      end

      def rails_config
        config.rails_config
      end

      def exclusions
        rails_config.skylight.exclusions
      end

    end
  end
end
