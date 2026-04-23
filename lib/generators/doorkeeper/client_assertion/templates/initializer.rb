# frozen_string_literal: true

Doorkeeper::ClientAssertion.configure do
  # Algorithms accepted for JWT client assertion signatures.
  # Default: %w[RS256 ES256]
  # client_assertion_algorithms %w[RS256 ES256]

  # Clock skew tolerance in seconds applied when validating exp, nbf, and iat claims.
  # Default: 300
  # jwt_assertion_exp_tolerance 300

  # Callback invoked when JWT verification fails. Useful for logging or monitoring.
  # Default: no-op
  # on_jwt_verification_failure ->(error, context) do
  #   Rails.logger.warn "[ClientAssertion] #{error.class}: #{error.message} (app: #{context[:application_id]})"
  # end
end
