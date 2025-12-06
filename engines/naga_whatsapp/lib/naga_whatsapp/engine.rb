require "whatsapp_sdk"

module NagaWhatsapp
  class Engine < ::Rails::Engine
    isolate_namespace NagaWhatsapp

    # This is to initializer the dependet gem whatsapp_sdk. 
    # Put initializer code here instead of config/initializer in the main app or the engine
    initializer "naga_whatsapp.config_external_sdk" do |app|
      WhatsappSdk.configure do |config|
        config.access_token = NagaWhatsapp.whatsapp_sdk_access_token # taken from initialiser for NagaWhatsapp in main app
        config.api_version = NagaWhatsapp.whatsapp_sdk_api_version # taken from initialiser for NagaWhatsapp in main app
        config.logger = Logger.new(STDOUT) # optional, Faraday logger to attach
        config.logger_options = { bodies: true } # optional, they are all valid logger_options for Faraday
      end
    end

  end
end
