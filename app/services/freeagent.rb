require 'net/http'
require 'uri'
require 'json'

class FreeagentService
  TOKEN_URL = 'https://api.freeagent.com/v2/token_endpoint_here'
  API_BASE = 'https://api.freeagent.com/v2'

  def initialize
    @client_id = Rails.application.credentials.freeagent_oauth_identifier
    @client_secret = Rails.application.credentials.freeagent_secret
    @access_token = fetch_access_token # Or load from storage if you've cached it
  end

  def fetch_access_token
    # Example only; replace with your token fetching logic or use a gem
    uri = URI.parse(TOKEN_URL)
    response = Net::HTTP.post_form(uri, {
      'grant_type' => 'client_credentials',
      'client_id' => @client_id,
      'client_secret' => @client_secret
    })

    body = JSON.parse(response.body)
    body['access_token']
  end

  def headers
    {
      'Authorization' => "Bearer #{@access_token}",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end

  def find_contact_by_email(email)
    uri = URI("#{API_BASE}/contacts?email=#{URI.encode_www_form_component(email)}")
    res = Net::HTTP.get_response(uri, headers)
    JSON.parse(res.body)
  end

  def create_invoice(contact_id, params = {})
    uri = URI("#{API_BASE}/invoices")
    request = Net::HTTP::Post.new(uri, headers)
    request.body = {
      invoice: {
        contact: "#{API_BASE}/contacts/#{contact_id}",
        dated_on: Date.today.to_s,
        payment_terms_in_days: 30,
        currency: "GBP",
        items: [
          {
            description: params[:description] || "Service",
            unit_price: params[:amount] || 100.0,
            quantity: 1
          }
        ]
      }
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    JSON.parse(response.body)
  end
end
