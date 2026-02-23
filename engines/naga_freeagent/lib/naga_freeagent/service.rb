# frozen_string_literal: true

require "faraday"
require "oauth2"

module NagaFreeagent
  module Service
    BASE_URL = "https://api.freeagent.com/v2"
    AUTHORIZE_URL = "https://api.freeagent.com/v2/approve_app"
    TOKEN_URL = "https://api.freeagent.com/v2/token_endpoint"

    def self.client(access_token = nil)
      Faraday.new(url: BASE_URL) do |faraday|
        faraday.request :json # for requests with JSON bodies
        faraday.response :json, parser_options: { symbolize_names: true } # for JSON responses
        faraday.adapter Faraday.default_adapter # Set up adapter for `Net::HTTP`
        faraday.headers['User-Agent'] = "NagaFreeagent Gem v#{NagaFreeagent::VERSION}"
        faraday.headers['Accept'] = "application/json"
        faraday.headers['Authorization'] = "Bearer #{access_token}" if access_token
      end
    end

    def self.oauth_client
      OAuth2::Client.new(
        NagaFreeagent.configuration.oauth_id,
        NagaFreeagent.configuration.oauth_secret,
        site: BASE_URL, # FreeAgent's base URL for the OAuth calls
        authorize_url: AUTHORIZE_URL,
        token_url: TOKEN_URL
      )
    end

    def self.authorize_url(redirect_uri, state = nil)
      oauth_client.auth_code.authorize_url(
        redirect_uri: redirect_uri,
        scope: "bank_accounts", # Request necessary scope, e.g., 'bank_accounts'
        state: state
      )
    end

    def self.get_access_token(code, redirect_uri)
      oauth_client.auth_code.get_token(code, redirect_uri: redirect_uri)
    end

    def self.get_banks(access_token)
      response = client(access_token).get("bank_accounts")
      if response.success?
        response.body
      else
        Rails.logger.error "FreeAgent API error (get_banks): Status #{response.status}, Body: #{response.body}"
        { error: "FreeAgent API error: Status #{response.status}", details: response.body }
      end
    end

    def self.refresh_access_token(refresh_token)
      OAuth2::AccessToken.new(oauth_client, nil, refresh_token: refresh_token).refresh!
    end
  end
end
