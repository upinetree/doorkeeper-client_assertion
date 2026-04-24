# frozen_string_literal: true

module Doorkeeper
  module ClientAssertion
    class Config
      DEFAULTS = {
        client_assertion_algorithms: %w[RS256 ES256],
        jwt_assertion_exp_tolerance: 300,
        on_jwt_verification_failure: ->(_error, _context) { nil }
      }.freeze

      DEFAULTS.each_key { |option| attr_reader option }

      def initialize(values = {})
        DEFAULTS.each do |key, default|
          instance_variable_set("@#{key}", values.fetch(key, default))
        end
      end

      class Builder
        def initialize
          @values = {}
        end

        DEFAULTS.each_key do |option|
          define_method(option) do |value = nil, &block|
            @values[option] = block || value
          end
        end

        def build
          Config.new(@values)
        end
      end
    end

    def self.configure(&block)
      builder = Config::Builder.new
      builder.instance_eval(&block) if block
      @config = builder.build
    end

    def self.configuration
      @config || configure
    end
  end
end
