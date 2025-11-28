WhatsappSdk.configure do |config|
  config.access_token = Rails.application.credentials.meta.access_token
  config.api_version = "v19.0"
  config.logger = Logger.new(STDOUT) # optional, Faraday logger to attach
  config.logger_options = { bodies: true } # optional, they are all valid logger_options for Faraday
end