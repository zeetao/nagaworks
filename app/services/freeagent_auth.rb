# app/services/freeagent_auth.rb
module FreeagentAuth
  def self.get_access_token
    Configuration.get('freeagent_access_token')
  end

  def self.get_refresh_token
    Configuration.get('freeagent_refresh_token')
  end

  def self.get_expires_at
    expires_at = Configuration.get('freeagent_expires_at')
    expires_at.present? ? Time.parse(expires_at) : nil
  end

  def self.set_tokens(access_token, refresh_token, expires_at)
    Configuration.set('freeagent_access_token', access_token)
    Configuration.set('freeagent_refresh_token', refresh_token)
    Configuration.set('freeagent_expires_at', expires_at.to_s)
  end

  def self.access_token_expired?
    expires_at = get_expires_at
    expires_at.present? && expires_at <= Time.current + 5.minutes # Refresh 5 minutes before actual expiry
  end

  def self.refresh_tokens!
    current_refresh_token = get_refresh_token
    if current_refresh_token.present?
      new_token_obj = NagaFreeagent::Service.refresh_access_token(current_refresh_token)
      set_tokens(new_token_obj.token, new_token_obj.refresh_token, Time.at(new_token_obj.expires_at))
      new_token_obj.token
    else
      nil
    end
  rescue OAuth2::Error => e
    Rails.logger.error "FreeAgent token refresh failed: #{e.message}"
    nil
  end
end
