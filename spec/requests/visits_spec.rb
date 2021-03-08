require 'rails_helper'

RSpec.describe "Visits", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/visits/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/visits/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/visits/create"
      expect(response).to have_http_status(:success)
    end
  end

end
