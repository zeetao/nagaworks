require 'json'
require 'net/http'

class Whatsapp
  
  @@whatsapp_config_all = NagaWhatsapp.whatsapp_numbers_config

  @@whatsappflow_survey_id = "878803277906154"
  
  def initialize(environment="development")
    @wa_client = WhatsappSdk::Api::Client.new
    @wa_config = @@whatsapp_config_all[environment]
  end
  
  def send_message(recipient_number, message_text)
    sender_id = @wa_config[:phone_number_id]
    
    # Usage: wa_client.send_message("60123456789", "Hello from RakanTani")
    @wa_client.messages.send_text(sender_id: sender_id, recipient_number: recipient_number ,message: message_text)
  end
  
  def send_location(recipient_number, location_name, location_address, latitude, longitude)
    sender_id = @wa_config[:phone_number_id]
    
    # usage wa_client.send_location("60123456789", "my house", "Kiara Park Condo", 3.154095731395855, 101.62540377329339)
    @wa_client.messages.send_location(sender_id: sender_id, recipient_number: recipient_number, longitude: longitude, latitude: latitude, name: location_name, address: location_address)
  end
  
  def send_image(recipient_number, imagepath)
    sender_id = @wa_config[:phone_number_id]
    
    image = client.media.upload(sender_id: sender_id, file_path: imagepath, type: "image/png")
    @wa_client.messages.send_image(sender_id: sender_id, recipient_number: recipient_number, image_id: image.id)
  end
  
      
  def send_sticker(recipient_number, stickerpath)
    sender_id = @wa_config[:phone_number_id]
    
    # upload a sticker and send it
    sticker = @wa_client.media.upload(sender_id: sender_id, file_path: stickerpath, type: "image/webp")
    @wa_client.messages.send_sticker(sender_id: sender_id, recipient_number: recipient_number, sticker_id: sticker.id)  
  end
  
  def get_templates
    business_id = @wa_config[:business_id]
  
    @wa_client.templates.list(business_id: business_id).records
    
  end
  
  def send_template(recipient_number, language, template_name, parameters)
    sender_id = @wa_config[:phone_number_id]
    
    @wa_client.messages.send_template(
      sender_id: sender_id,
      recipient_number: recipient_number,
      name: template_name,
      language:  language,
      components: [
        {
          type: "BODY",
          parameters: parameters
        }
      ]
    )
  end
  
  def send_template_alert(recipient_number, alert_text)
    
    send_template(recipient_number, "en", "alert_message", [
      { parameter_name: "notification", type: "text", text: alert_text}
    ])
  end
  
  def send_template_farmingupdate_my(recipient_number, update_text)
    send_template(recipient_number, "ms", "daily_farming_update_my", [
      { parameter_name: "update", type: "text", text: update_text}
    ])
  end
  
  def send_template_farmingupdate(recipient_number, update_text)
    send_template(recipient_number, "en", "daily_farming_update", [
      { parameter_name: "update", type: "text", text: update_text}
    ])
  end
  
  def send_template_helloworld(recipient_number)
    send_template(recipient_number, "en_US", "hello_world", [])
  end

  def update_flow(flow_id, flow_name, flow_data)
    # curl -X POST 'https://graph.facebook.com/v22.0/2241223466360904' \
    # --header 'Authorization: Bearer <TOKEN> \
    # --header "Content-Type: application/json" \
    # --data '{
    #   "name": "Rakantani Feedback",
    #   "categories": [ "OTHER" ],
    #   "publish" : true,
    #   "flow_json" : stringified json
    # }'

    data = {
      name: flow_name,
      categories: [ "OTHER" ],
      flow_json: flow_data.to_json,
      status: "PUBLISHED"
    }
    @wa_client.send_request(endpoint: "#{flow_id}", params: data, http_method: 'post')
  end

  def create_flow(flow_name, flow_data)
    # curl -X POST 'https://graph.facebook.com/606475519041386/flows' \
    # --header 'Authorization: Bearer {ACCESS-TOKEN}' \
    # --header "Content-Type: application/json" \
    # --data '{
    #   "name": "My first flow",
    #   "categories": [ "OTHER" ],
    #   "flow_json" : "stringified json",
    #   "publish" : true
    # }'

    data = {
      name: flow_name,
      categories: [ "OTHER" ],
      flow_json: flow_data.to_json,
      status: "PUBLISHED"
    }
    @wa_client.send_request(endpoint: "606475519041386/flows", params: data, http_method: 'post')
  end

  def publish(flow_id)
    @wa_client.send_request(endpoint: "#{flow_id}/publish", http_method: 'post')
  end

  def get_all_flows(environment)
    @wa_client.send_request(endpoint: "#{@@whatsapp_config_all[environment][:business_id]}/flows", http_method: 'get')
  end

  def get_flow_details(flow_id)
    begin
      endpoint = "#{flow_id}?"
      @wa_client.send_request(endpoint: endpoint, http_method: 'get')
    rescue WhatsappSdk::Api::Responses::HttpResponseError => e
      if e.http_status == 200
        return e.body
      else
        raise e
      end
    end
  end
end