require 'rails_helper'

RSpec.describe CustomersController, type: :controller do
  let(:valid_attributes) do
    { 
      name: "John Doe", 
      email: "john.doe@example.com", 
      phone: "123-456-7890",
      address: 'the restaurant at the end of the universe'
    }
  end

  let(:invalid_attributes) do
    { 
      name: "", 
      email: "invalid_email", 
      phone: "asdasdasd",
      address: ''
    }
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new Customer" do
        expect {
          post :create, params: { customer: valid_attributes }
        }.to change(Customer, :count).by(1)
      end

      it "redirects to the created customer" do
        post :create, params: { customer: valid_attributes }
        expect(response).to redirect_to(Customer.last)
      end

      it "returns a successful response" do
        post :create, params: { customer: valid_attributes }
        expect(response).to have_http_status(:found) # 302 for redirect
      end
    end

    context "with invalid parameters" do
      it "does not create a new Customer" do
        expect {
          post :create, params: { customer: invalid_attributes }
        }.not_to change(Customer, :count)
      end

      it "re-renders the 'new' template" do
        post :create, params: { customer: invalid_attributes }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    let(:customer) { Customer.create!(valid_attributes) }

    context "with valid parameters" do
      let(:new_attributes) do
        { name: "Jane Doe", email: "jane.doe@example.com", phone: "098-765-4321" }
      end

      it "updates the requested customer" do
        put :update, params: { id: customer.id, customer: new_attributes }
        customer.reload
        expect(customer.name).to eq("Jane Doe")
        expect(customer.email).to eq("jane.doe@example.com")
      end

      it "redirects to the customer" do
        put :update, params: { id: customer.id, customer: new_attributes }
        expect(response).to redirect_to(customer)
      end
    end

    context "with invalid parameters" do
      it "does not update the customer" do
        put :update, params: { id: customer.id, customer: invalid_attributes }
        customer.reload
        expect(customer.name).not_to eq("")
      end

      it "re-renders the 'edit' template" do
        put :update, params: { id: customer.id, customer: invalid_attributes }
        expect(response).to render_template("edit")
      end
    end
  end
end
