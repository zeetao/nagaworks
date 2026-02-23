# app/services/freeagent_api_service.rb
require_relative 'freeagent_auth'

class FreeagentApiService
  def self.get_banks
    access_token = FreeagentAuth.get_access_token

    if access_token.nil?
      Rails.logger.warn "FreeagentApiService: No access token found. User needs to re-authorize."
      return { error: "No FreeAgent access token. Please authorize." }
    end

    if FreeagentAuth.access_token_expired?
      Rails.logger.info "FreeagentApiService: Access token expired, attempting to refresh."
      access_token = FreeagentAuth.refresh_tokens!
      if access_token.nil?
        Rails.logger.error "FreeagentApiService: Failed to refresh access token. User needs to re-authorize."
        return { error: "Failed to refresh FreeAgent access token. Please re-authorize." }
      end
    end

    NagaFreeagent::Service.get_banks(access_token)
  end
end
