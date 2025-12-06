require 'json'
require 'net/http'

module NagaWhatsapp
  class << self
    def client
      @client ||= WhatsappSdk::Api::Client.new
    end

    def wa_config(environment = "development")
      whatsapp_numbers_config[environment]
    end

    def send_message(recipient_number, message_text, environment: "development")
      config = wa_config(environment)
      sender_id = config[:phone_number_id]
      client.messages.send_text(sender_id: sender_id, recipient_number: recipient_number, message: message_text)
    end

    def send_location(recipient_number, location_name, location_address, latitude, longitude, environment: "development")
      config = wa_config(environment)
      sender_id = config[:phone_number_id]
      client.messages.send_location(sender_id: sender_id, recipient_number: recipient_number, longitude: longitude, latitude: latitude, name: location_name, address: location_address)
    end

    def send_image(recipient_number, imagepath, environment: "development")
      config = wa_config(environment)
      sender_id = config[:phone_number_id]
      image = client.media.upload(sender_id: sender_id, file_path: imagepath, type: "image/png")
      client.messages.send_image(sender_id: sender_id, recipient_number: recipient_number, image_id: image.id)
    end

    def send_sticker(recipient_number, stickerpath, environment: "development")
      config = wa_config(environment)
      sender_id = config[:phone_number_id]
      sticker = client.media.upload(sender_id: sender_id, file_path: stickerpath, type: "image/webp")
      client.messages.send_sticker(sender_id: sender_id, recipient_number: recipient_number, sticker_id: sticker.id)
    end

    def get_templates(environment: "development")
      config = wa_config(environment)
      business_id = config[:business_id]
      client.templates.list(business_id: business_id).records
    end

    def send_template(recipient_number, language, template_name, parameters, environment: "development")
      config = wa_config(environment)
      sender_id = config[:phone_number_id]
      client.messages.send_template(
        sender_id: sender_id,
        recipient_number: recipient_number,
        name: template_name,
        language: language,
        components: [
          {
            type: "BODY",
            parameters: parameters
          }
        ]
      )
    end

    def send_template_alert(recipient_number, alert_text, environment: "development")
      send_template(recipient_number, "en", "alert_message", [
        { parameter_name: "notification", type: "text", text: alert_text}
      ], environment: environment)
    end

    def send_template_farmingupdate_my(recipient_number, update_text, environment: "development")
      send_template(recipient_number, "ms", "daily_farming_update_my", [
        { parameter_name: "update", type: "text", text: update_text}
      ], environment: environment)
    end

    def send_template_farmingupdate(recipient_number, update_text, environment: "development")
      send_template(recipient_number, "en", "daily_farming_update", [
        { parameter_name: "update", type: "text", text: update_text}
      ], environment: environment)
    end

    def send_template_helloworld(recipient_number, environment: "development")
      send_template(recipient_number, "en_US", "hello_world", [], environment: environment)
    end

    def update_flow(flow_id, flow_name, flow_data)
      data = {
        name: flow_name,
        categories: [ "OTHER" ],
        flow_json: flow_data.to_json,
        status: "PUBLISHED"
      }
      client.send_request(endpoint: "#{flow_id}", params: data, http_method: 'post')
    end

    def create_flow(flow_name, flow_data)
      data = {
        name: flow_name,
        categories: [ "OTHER" ],
        flow_json: flow_data.to_json,
        status: "PUBLISHED"
      }
      client.send_request(endpoint: "606475519041386/flows", params: data, http_method: 'post')
    end

    def publish(flow_id)
      client.send_request(endpoint: "#{flow_id}/publish", http_method: 'post')
    end

    def get_all_flows(environment: "development")
      config = wa_config(environment)
      client.send_request(endpoint: "#{config[:business_id]}/flows", http_method: 'get')
    end

    def get_flow_details(flow_id)
      begin
        endpoint = "#{flow_id}?"
        client.send_request(endpoint: endpoint, http_method: 'get')
      rescue WhatsappSdk::Api::Responses::HttpResponseError => e
        if e.http_status == 200
          return e.body
        else
          raise e
        end
      end
    end
  end
end