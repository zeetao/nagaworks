NagaWhatsapp.configure do |config|
  config.whatsapp_sdk_access_token = Rails.application.credentials.meta.access_token
  config.whatsapp_sdk_api_version = "v19.0"
end