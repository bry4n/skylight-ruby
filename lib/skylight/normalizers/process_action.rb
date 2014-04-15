module Skylight
  module Normalizers
    class ProcessAction < Normalizer
      register "process_action.action_controller"

      CAT = "app.controller.request".freeze
      PAYLOAD_KEYS = %w[ controller action params format method path ].map(&:to_sym).freeze

      def normalize(trace, name, payload)
        endpoint = trace.endpoint = controller_action(payload)
        unless excluded?(endpoint)
          [ CAT, trace.endpoint, nil, normalize_payload(payload) ]
        else
          puts endpoint
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

      def excluded?(endpoint)
        return false unless rails_config
        exclusions.include?(endpoint)
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
