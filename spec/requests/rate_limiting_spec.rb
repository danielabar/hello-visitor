# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Rate limiting" do
  describe "POST /visits" do
    let(:limit) { ENV.fetch("RACK_ATTACK_VISITS_LIMIT", "60").to_i }
    let(:headers) do
      { "REMOTE_ADDR" => "1.2.3.4", "CONTENT_TYPE" => "application/json" }
    end
    let(:params) do
      {
        guest_timezone_offset: 0,
        user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36",
        url: "https://example.com/page",
        referrer: "https://www.google.com/"
      }.to_json
    end

    it "throttles requests from the same IP after the limit" do
      limit.times { post "/visits", params: params, headers: headers }
      post "/visits", params: params, headers: headers
      expect(response).to have_http_status(:too_many_requests)
    end

    it "does not throttle a different IP" do
      limit.times { post "/visits", params: params, headers: headers }
      post "/visits", params: params, headers: headers.merge("REMOTE_ADDR" => "5.6.7.8")
      expect(response).not_to have_http_status(:too_many_requests)
    end
  end

  describe "GET /search" do
    let(:limit) { ENV.fetch("RACK_ATTACK_SEARCH_LIMIT", "30").to_i }
    let(:headers) { { "REMOTE_ADDR" => "1.2.3.4" } }

    it "throttles requests from the same IP after the limit" do
      limit.times { get "/search", headers: headers }
      get "/search", headers: headers
      expect(response).to have_http_status(:too_many_requests)
    end

    it "does not throttle a different IP" do
      limit.times { get "/search", headers: headers }
      get "/search", headers: headers.merge("REMOTE_ADDR" => "5.6.7.8")
      expect(response).not_to have_http_status(:too_many_requests)
    end
  end
end
