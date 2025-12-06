require "naga_whatsapp/version"
require "naga_whatsapp/engine"

module NagaWhatsapp
  # white list parameters that can be configured in this gem
  mattr_accessor :whatsapp_sdk_access_token, :whatsapp_sdk_api_version, :whatsapp_numbers_config # Use mattr_accessor for shared config

  def self.configure
    yield self
  end
end
