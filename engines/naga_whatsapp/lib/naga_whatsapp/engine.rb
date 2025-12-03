module NagaWhatsapp
  class Engine < ::Rails::Engine
    isolate_namespace NagaWhatsapp

    # This is to initializer the dependet gem whatsapp_sdk. 
    # Put initializer code here instead of config/initializer in the main app or the engine
    initializer "naga_whatsapp.config_external_sdk" do |app|
      WhatsappSdk.configure do |config|
        config.access_token = Rails.application.credentials.meta.access_token
        config.api_version = "v19.0"
        config.logger = Logger.new(STDOUT) # optional, Faraday logger to attach
        config.logger_options = { bodies: true } # optional, they are all valid logger_options for Faraday
      end
    end

  end
end
