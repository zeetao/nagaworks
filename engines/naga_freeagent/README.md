# NagaFreeagent

NagaFreeagent is a Ruby gem designed to facilitate integration with the FreeAgent accounting API. It provides a structured way to interact with FreeAgent's OAuth2 authentication and various API endpoints.

## Installation

To use this gem in your Rails application, add the following line to your `Gemfile`:

```ruby
gem "naga_freeagent", path: "engines/naga_freeagent"
```

Then, run `bundle install` to install the gem and its dependencies:

```bash
bundle install
```

## Configuration

Before using the gem, you need to configure your FreeAgent OAuth application credentials. It's recommended to store these securely, for example, using Rails credentials.

You can configure the gem using a `NagaFreeagent.configure` block, typically in an initializer (e.g., `config/initializers/naga_freeagent.rb`):

```ruby
# config/initializers/naga_freeagent.rb
NagaFreeagent.configure do |config|
  config.oauth_id = Rails.application.credentials.freeagent&.oauth_id
  config.oauth_secret = Rails.application.credentials.freeagent&.oauth_secret
end
```

## Database Migrations

The NagaFreeagent gem includes its own database migrations for managing FreeAgent tokens and other configurations. To apply these migrations to your application:

1.  **Copy the migrations:** Run the following Rake task to copy the engine's migrations to your application's `db/migrate` directory:
    ```bash
    rails naga_freeagent:install:migrations
    ```
2.  **Run the migrations:** Execute the standard Rails migration command:
    ```bash
    rails db:migrate
    ```

## Usage

The primary interaction with the FreeAgent API is through the `NagaFreeagent::Service` class.

### OAuth Authorization Flow

To initiate the OAuth 2.0 authorization flow:

```ruby
# Generate the authorization URL
redirect_uri = "YOUR_REDIRECT_URI" # Must match your FreeAgent app settings
state = SecureRandom.hex(16) # A random string to prevent CSRF
authorization_url = NagaFreeagent::Service.authorize_url(redirect_uri, state)

# Redirect your user to authorization_url
# e.g., redirect_to authorization_url
```

To exchange the authorization code for an access token:

```ruby
# After the user authorizes your app and is redirected back to your redirect_uri
code = params[:code] # The authorization code from FreeAgent
redirect_uri = "YOUR_REDIRECT_URI" # Must be the same as used for authorize_url

tokens = NagaFreeagent::Service.get_access_token(code, redirect_uri)
access_token = tokens["access_token"]
refresh_token = tokens["refresh_token"]
expires_at = tokens["expires_at"] # Unix timestamp when the token expires
```

### Refreshing Access Tokens

Access tokens have a limited lifespan. You can use the refresh token to obtain a new access token without re-authenticating the user:

```ruby
current_refresh_token = "YOUR_STORED_REFRESH_TOKEN"
new_tokens = NagaFreeagent::Service.refresh_access_token(current_refresh_token)
new_access_token = new_tokens["access_token"]
new_refresh_token = new_tokens["refresh_token"] # Refresh token might also be new
new_expires_at = new_tokens["expires_at"]
```

### Fetching Bank Accounts

Once you have a valid access token, you can fetch bank accounts:

```ruby
access_token = "YOUR_VALID_ACCESS_TOKEN"
banks = NagaFreeagent::Service.get_banks(access_token)
# banks will be an array of bank account data
```

Error handling is built into the `NagaFreeagent::Service` methods, typically raising `NagaFreeagent::Error` or `OAuth2::Error` on failures.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/naga_freeagent.
