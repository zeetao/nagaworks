awanmulan_access_token = "EAANi8M4lWZAEBPpWkw3qvu9NrZAaR2YKbSdL7sw5RLO5nuiMMuN5t8KwGzy6tjLPrDBTkSCwkl6LGNS1T4Ek6N8HPuyShw6dY77R3e0FhJnzMBYZBbiO707G7dKMRAvZBe05acm8vFrS8mwHIvVxds9JEMMxVEZAqzFDDpZBeWnGXgviJXzGeTpJvjC0PIIRY1k53TXIdzDiflCfj45m3KvFubXi7CAZBtkBqDHTxOq"

WhatsappSdk.configure do |config|
  config.access_token = awanmulan_access_token
  config.api_version = "v19.0"
  config.logger = Logger.new(STDOUT) # optional, Faraday logger to attach
  config.logger_options = { bodies: true } # optional, they are all valid logger_options for Faraday
end