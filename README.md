# doorkeeper-client_assertion

`private_key_jwt` client authentication for [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper).

## Supported specifications

- [Client Authentication using private_key_jwt](https://openid.net/specs/openid-connect-core-1_0.html#ClientAuthentication) (OpenID Connect Core 1.0 Section 9)
- [RFC 7521](https://datatracker.ietf.org/doc/html/rfc7521) — Assertion Framework for OAuth 2.0 Client Authentication
- [RFC 7523](https://datatracker.ietf.org/doc/html/rfc7523) — JWT Profile for OAuth 2.0 Client Authentication

## Installation

Generate and run the migrations:

```sh
rails generate doorkeeper:client_assertion:migration
rails generate doorkeeper:remove_application_secret_not_null_constraint
rake db:migrate
```

The first migration adds:
- `jwks` — stores the client's public keys as a JSON Web Key Set
- `token_endpoint_auth_method` — records the authentication method agreed at registration (`private_key_jwt`, `client_secret_basic`, etc.)

The second migration removes the NOT NULL constraint from `secret`, which is required because `private_key_jwt` clients do not use a client secret.

Generate the initializer:

```sh
rails generate doorkeeper:client_assertion:install
```

## Configuration

All settings are optional. The defaults cover the most common use cases.

- **`client_assertion_algorithms`**
  - Algorithms accepted for JWT client assertion signatures.
  - Default: `%w[RS256 ES256]`
  - Example: `client_assertion_algorithms %w[RS256 RS384 RS512 ES256 ES384 ES512]`

- **`jwt_assertion_exp_tolerance`**
  - Clock skew tolerance in seconds applied when validating `exp`, `nbf`, and `iat` claims.
  - Default: `300` (5 minutes)
  - Example: `jwt_assertion_exp_tolerance 600`

- **`on_jwt_verification_failure`**
  - Callback invoked when JWT verification fails. Useful for logging or monitoring.
  - Default: no-op
  - Example:
    ```ruby
    on_jwt_verification_failure ->(error, context) do
      Rails.logger.warn "[ClientAssertion] #{error.class}: #{error.message} (app: #{context[:application_id]})"
    end
    ```

## Usage

### Registering a client with private_key_jwt

Create an `Doorkeeper::Application` with `token_endpoint_auth_method: 'private_key_jwt'` and a JWKS containing the client's public key(s):

```ruby
Doorkeeper::Application.create!(
  name: 'My Client',
  redirect_uri: 'https://client.example.com/callback',
  token_endpoint_auth_method: 'private_key_jwt',
  jwks: {
    keys: [
      {
        kty: 'EC',
        crv: 'P-256',
        x: 'WKn-ZIGevcwGIyyrzFoZNBdaq9_TsqzGl96oc0CWuis',
        y: 'y77t-RvAHRKTsSGdIYUfweuOvwrvDD-Q3Hv5J0fSKbE',
        kid: 'key-1'
      }
    ]
  }.to_json
)
```

When the JWKS contains multiple keys, each key MUST have a `kid` so the server can select the correct one (OpenID Connect Core Section 10.1).

### Authenticating at the token endpoint

Send a signed JWT as `client_assertion` with `client_assertion_type` set to the registered URN ([RFC 7521 Section 4.2](https://datatracker.ietf.org/doc/html/rfc7521#section-4.2)):

```
POST /oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code
&code=...
&redirect_uri=https://client.example.com/callback
&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer
&client_assertion=eyJhbGc...
```

The JWT must contain the following claims ([RFC 7523 Section 3](https://datatracker.ietf.org/doc/html/rfc7523#section-3)):

| Claim | Requirement | Value |
|-------|-------------|-------|
| `iss` | REQUIRED (RFC 7523) | client_id |
| `sub` | REQUIRED (RFC 7523) | client_id |
| `aud` | REQUIRED (RFC 7523) | token endpoint URL (without query string) |
| `exp` | REQUIRED (RFC 7523) | expiration time |
| `iat` | REQUIRED (OIDC Core Section 9) | issuance time |