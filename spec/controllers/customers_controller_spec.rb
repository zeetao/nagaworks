require 'rails_helper'

RSpec.describe CustomersController, type: :controller do
  render_views
  
  describe "POST #create" do
    before(:each) {
      request.headers["Accept"] = "text/vnd.turbo-stream.html"
      post :create, params: { customer: attributes }, as: :turbo_stream
    }
    context "with valid parameters" do
      let(:attributes) do
        { 
          name: "John Doe", 
          email: "john.doe@example.com", 
          phone: "123-456-7890",
          address: 'the restaurant at the end of the universe'
        }
      end
      
      it "creates a new Customer" do
        expect(Customer.count).to eq 1
      end
      
      it "returns a successful response" do
        expect(response).to have_http_status(:success)
      end

      it "responds with turbostream html" do
        expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      end
      
      it "renders a turbostream frame" do
        expect(response.body).to include("<turbo-stream action=\"replace\" target=\"notices\">")
      end
      
      it "renders notice that says 'Customer was successfully created'" do
        expect(response.body).to include("Customer was successfully created.")
      end
      
    end

    context "with invalid parameters" do
      let(:attributes) do
        { 
          name: "", 
          email: "invalid_email", 
          phone: "asdasdasd",
          address: ''
        }
      end

      it "does not create a new Customer" do
        expect(Customer.count).not_to eq 1
      end
      
      it "returns a failure response" do
        expect(response).to have_http_status(422)
      end
      
      it "responds with turbostream html" do
        expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      end
      
      it "renders a turbostream frame" do
        expect(response.body).to include("<turbo-stream action=\"replace\" target=\"notices\">")
      end
      
      it "renders notice that says 'Name can't be blank" do
        expect(response.body).to include("Name can&#39;t be blank")
      end

    end
  end

end
