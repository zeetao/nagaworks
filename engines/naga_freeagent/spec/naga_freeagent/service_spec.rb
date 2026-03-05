# frozen_string_literal: true

require "spec_helper"

RSpec.describe NagaFreeagent::Service do
  describe ".authorize_url" do
    it "returns the correct FreeAgent authorization URL" do
      url = described_class.authorize_url("http://localhost/callback", "random_state")
      expect(url).to include("https://api.freeagent.com/v2/approve_app")
      expect(url).to include("client_id=test_id")
      expect(url).to include("redirect_uri=http%3A%2F%2Flocalhost%2Fcallback")
      expect(url).to include("state=random_state")
      expect(url).to include("scope=bank_accounts")
    end
  end

  describe ".get_banks" do
    let(:access_token) { "fake_token" }

    it "fetches bank accounts successfully" do
      stub_request(:get, "https://api.freeagent.com/v2/bank_accounts")
        .with(headers: { 'Authorization' => "Bearer #{access_token}" })
        .to_return(
          status: 200,
          body: { bank_accounts: [{ id: 1, name: "Business Account" }] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = described_class.get_banks(access_token)
      expect(response[:bank_accounts].first[:name]).to eq("Business Account")
    end

    it "handles API errors gracefully" do
      stub_request(:get, "https://api.freeagent.com/v2/bank_accounts")
        .to_return(
          status: 401,
          body: { error: "Unauthorized" }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = described_class.get_banks(access_token)
      expect(response[:error]).to include("FreeAgent API error: Status 401")
    end
  end
end
