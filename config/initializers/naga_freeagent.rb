# config/initializers/naga_freeagent.rb
Rails.application.config.after_initialize do
  if defined?(NagaFreeagent)
    NagaFreeagent.configure do |config|
      config.oauth_id = Rails.application.credentials.freeagent.oauth_id
      config.oauth_secret = Rails.application.credentials.freeagent.oauth_secret
    end
  end
end
