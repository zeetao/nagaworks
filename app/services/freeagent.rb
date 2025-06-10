require 'net/http'
require 'uri'
require 'json'

class Freeagent
  TOKEN_URL = 'https://api.freeagent.com/v2/token_endpoint'
  API_BASE = 'https://api.freeagent.com/v2'

  def initialize
    @client_id = Rails.application.credentials.freeagent_oauth_identifier
    @client_secret = Rails.application.credentials.freeagent_secret
    @access_token = fetch_or_refresh_access_token # Or load from storage if you've cached it
  end
  
  def get_manual_tokens_from_browser
    # If the refresh token expires, you have to go to this link to get a new one
    # The link opens a Google Developers page with the Oauth client code and secret prefilled
    # You then have to click "Step 1" - write Freeagent into "input your own scopes"
    # Click "Authorise API"
    # It will bring you to the freeagent login screen where you have to login to the freeagent account of choice
    # And then on the browser it gives you the refresh token and access token
    # This retarded process is documented here https://dev.freeagent.com/docs/quick_start
    
    # As long as the refresh token is stil valid, you can use it to continuously refresh the access token
    # Both need to be stored in a persistent storage
    
    "https://developers.google.com/oauthplayground/#step3&url=https%3A%2F%2F&content_type=application%2Fjson&http_method=GET&useDefaultOauthCred=unchecked&oauthEndpointSelect=Custom&oauthAuthEndpointValue=https%3A%2F%2Fapi.freeagent.com%2Fv2%2Fapprove_app&oauthTokenEndpointValue=https%3A%2F%2Fapi.freeagent.com%2Fv2%2Ftoken_endpoint&oauthClientId=#{Rails.application.credentials.freeagent_oauth_identifier}&oauthClientSecret=#{Rails.application.credentials.freeagent_secret}&includeCredentials=checked&accessTokenType=bearer&autoRefreshToken=unchecked&accessType=offline&prompt=consent&response_type=code&wrapLines=on"
  
  end

  def fetch_or_refresh_access_token
    cached = Rails.cache.read("freeagent_access_token")

    if cached && Time.now < cached[:expires_at]
      return cached[:token]
    else
      token, expires_in = fetch_access_token_from_api
      Rails.cache.write("freeagent_access_token", {
        token: token,
        expires_at: Time.now + expires_in.to_i.seconds - 30 # buffer to avoid expiry race
      })
      return token
    end
  end

  def fetch_access_token_from_api
    # Note: Use 'authorization_code' or 'refresh_token' depending on your flow
    uri = URI.parse(TOKEN_URL)
    res = Net::HTTP.post_form(uri, {
      'grant_type' => 'refresh_token',
      'client_id' => @client_id,
      'client_secret' => @client_secret
    })

    body = JSON.parse(res.body)
    token = body['access_token']
    expires_in = body['expires_in'] || 3600 # default to 1 hour if not specified
    [token, expires_in]
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
  
    return nil unless res.is_a?(Net::HTTPSuccess)
  
    body = JSON.parse(res.body)
    contacts = body["contacts"] || []
  
    # Find exact match (case-insensitive)
    contacts.find do |c|
      c_email = c["email"]
      c_email && email && c_email.downcase == email.downcase
    end
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
