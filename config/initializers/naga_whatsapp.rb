NagaWhatsapp.configure do |config|
  config.whatsapp_sdk_access_token = Rails.application.credentials.meta.access_token
  config.whatsapp_sdk_api_version = "v19.0"
  config.whatsapp_numbers_config = {
    "development" => {
      business_id: Rails.application.credentials.meta.business_id,
      phone_number_id: Rails.application.credentials.meta.development.phone_id,
      phone_number: Rails.application.credentials.meta.development.phone_num
    },
    "staging" => {
      business_id: "",
      phone_number_id: "",
      phone_number: ""
    }
  }
end