NagaWhatsapp.configure do |config|
  config.whatsapp_sdk_access_token = "test_token"
  config.whatsapp_sdk_api_version = "v19.0"
  config.whatsapp_numbers_config = {
    "test" => {
      business_id: "9876543210",
      phone_number_id: "1234567890",
      phone_number: "111111111"
    }
  }
end
