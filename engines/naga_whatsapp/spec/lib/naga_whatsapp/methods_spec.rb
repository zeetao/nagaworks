require 'rails_helper'

RSpec.describe NagaWhatsapp do
  let(:access_token) { "test_token" }
  let(:client) { WhatsappSdk::Api::Client.new(access_token, "v19.0") }
  let(:config) do
    {
      phone_number_id: "1234567890",
      business_id: "9876543210"
    }
  end

  before do
    allow(NagaWhatsapp).to receive(:client).and_return(client)
    allow(NagaWhatsapp).to receive(:wa_config).and_return(config)
  end

  describe ".send_message" do
    it "sends a text message" do
      recipient_number = "111111111"
      message_text = "Hello, world!"
      expected_params = {
        recipient_number: recipient_number,
        sender_id: config[:phone_number_id],
        message: message_text
      }
      expect(client.messages).to receive(:send_text).with(expected_params)
      NagaWhatsapp.send_message(recipient_number, message_text)
    end
  end

  describe ".send_location" do
    it "sends a location message" do
      recipient_number = "111111111"
      location_name = "Naga"
      location_address = "Naga Address"
      latitude = 1.2345
      longitude = -1.2345

      expected_params = {
        sender_id: config[:phone_number_id],
        recipient_number: recipient_number,
        longitude: longitude,
        latitude: latitude,
        name: location_name,
        address: location_address
      }

      expect(client.messages).to receive(:send_location).with(expected_params)
      NagaWhatsapp.send_location(recipient_number, location_name, location_address, latitude, longitude)
    end
  end

  describe ".send_image" do
    it "uploads an image and sends it" do
      recipient_number = "111111111"
      imagepath = "path/to/image.png"
      image_id = "image_id_123"

      upload_response = double("upload_response", id: image_id)
      allow(client.media).to receive(:upload).with(sender_id: config[:phone_number_id], file_path: imagepath, type: "image/png").and_return(upload_response)

      expected_params = {
        sender_id: config[:phone_number_id],
        recipient_number: recipient_number,
        image_id: image_id
      }
      expect(client.messages).to receive(:send_image).with(expected_params)
      NagaWhatsapp.send_image(recipient_number, imagepath)
    end
  end

  describe ".send_sticker" do
    it "uploads a sticker and sends it" do
      recipient_number = "111111111"
      stickerpath = "path/to/sticker.webp"
      sticker_id = "sticker_id_123"

      upload_response = double("upload_response", id: sticker_id)
      allow(client.media).to receive(:upload).with(sender_id: config[:phone_number_id], file_path: stickerpath, type: "image/webp").and_return(upload_response)

      expected_params = {
        sender_id: config[:phone_number_id],
        recipient_number: recipient_number,
        sticker_id: sticker_id
      }
      expect(client.messages).to receive(:send_sticker).with(expected_params)
      NagaWhatsapp.send_sticker(recipient_number, stickerpath)
    end
  end

  describe ".get_templates" do
    it "gets templates" do
      expect(client.templates).to receive(:list).with(business_id: config[:business_id]).and_return(double("templates", records: []))
      NagaWhatsapp.get_templates
    end
  end

  describe ".send_template" do
    it "sends a template message" do
      recipient_number = "111111111"
      language = "en"
      template_name = "my_template"
      parameters = [{ type: 'text', 'text': 'test' }]
      
      expected_params = {
        sender_id: config[:phone_number_id],
        recipient_number: recipient_number,
        name: template_name,
        language: language,
        components: [
          {
            type: "BODY",
            parameters: parameters
          }
        ]
      }
      
      expect(client.messages).to receive(:send_template).with(expected_params)
      NagaWhatsapp.send_template(recipient_number, language, template_name, parameters)
    end
  end

  describe ".update_flow" do
    it "sends a post request to update a flow" do
      flow_id = "12345"
      flow_name = "My Flow"
      flow_data = { screen: "SCREEN_1" }
      expected_endpoint = "#{flow_id}"
      expected_params = {
        name: flow_name,
        categories: [ "OTHER" ],
        flow_json: flow_data.to_json,
        status: "PUBLISHED"
      }

      expect(client).to receive(:send_request).with(endpoint: expected_endpoint, params: expected_params, http_method: 'post')
      NagaWhatsapp.update_flow(flow_id, flow_name, flow_data)
    end
  end

  describe ".create_flow" do
    it "sends a post request to create a flow" do
      flow_name = "My New Flow"
      flow_data = { screen: "SCREEN_1" }
      expected_endpoint = "606475519041386/flows"
      expected_params = {
        name: flow_name,
        categories: [ "OTHER" ],
        flow_json: flow_data.to_json,
        status: "PUBLISHED"
      }

      expect(client).to receive(:send_request).with(endpoint: expected_endpoint, params: expected_params, http_method: 'post')
      NagaWhatsapp.create_flow(flow_name, flow_data)
    end
  end

  describe ".publish" do
    it "sends a post request to publish a flow" do
      flow_id = "12345"
      expected_endpoint = "#{flow_id}/publish"
      expect(client).to receive(:send_request).with(endpoint: expected_endpoint, http_method: 'post')
      NagaWhatsapp.publish(flow_id)
    end
  end

  describe ".get_all_flows" do
    it "sends a get request to get all flows" do
      expected_endpoint = "#{config[:business_id]}/flows"
      expect(client).to receive(:send_request).with(endpoint: expected_endpoint, http_method: 'get')
      NagaWhatsapp.get_all_flows
    end
  end

  describe ".get_flow_details" do
    it "sends a get request to get flow details" do
      flow_id = "12345"
      expected_endpoint = "#{flow_id}?"
      expect(client).to receive(:send_request).with(endpoint: expected_endpoint, http_method: 'get')
      NagaWhatsapp.get_flow_details(flow_id)
    end
  end
end
