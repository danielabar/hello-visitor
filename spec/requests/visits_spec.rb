# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Visits" do
  let(:user) { create(:user) }
  let!(:visit1) { create(:visit, url: "https://example.com/page1", created_at: 5.days.ago) }
  let!(:visit2) { create(:visit, url: "https://example.com/page1", created_at: 1.day.ago) }
  let!(:visit3) { create(:visit, url: "https://example.com/page2", created_at: 1.day.ago) }

  context "when authenticated" do
    before do
      sign_in(user)
    end

    describe "GET /visits.json" do
      it "Returns all visits in the last month and some stats" do
        get "/visits.json"
        expect(response).to have_http_status(:success)

        parsed_body = response.parsed_body
        expect(parsed_body["summary"]["total_visits"]).to eq(3)

        expect(parsed_body["by_page"][0][0]).to eq("https://example.com/page1")
        expect(parsed_body["by_page"][0][1]).to eq(2)
        expect(parsed_body["by_page"][1][0]).to eq("https://example.com/page2")
        expect(parsed_body["by_page"][1][1]).to eq(1)

        expect(parsed_body["by_date"][0][0]).to eq(visit1.created_at.strftime("%Y-%m-%d"))
        expect(parsed_body["by_date"][0][1]).to eq(1)
        expect(parsed_body["by_date"][1][0]).to eq(visit2.created_at.strftime("%Y-%m-%d"))
        expect(parsed_body["by_date"][1][1]).to eq(2)

        expect(parsed_body["by_referrer"]).to eq([])
      end

      it "Returns visits filtered by url" do
        get "/visits.json", params: { visit_search: { url: "page1" } }
        expect(response).to have_http_status(:success)

        parsed_body = response.parsed_body
        expect(parsed_body["summary"]["total_visits"]).to eq(2)

        expect(parsed_body["by_page"].size).to eq(1)
        expect(parsed_body["by_page"][0][0]).to eq("https://example.com/page1")
        expect(parsed_body["by_page"][0][1]).to eq(2)

        expect(parsed_body["by_date"].size).to eq(2)
        expect(parsed_body["by_date"][0][1]).to eq(1) # visit1
        expect(parsed_body["by_date"][1][1]).to eq(1) # visit2

        expect(parsed_body["by_referrer"]).to eq([])
      end

      it "Returns visits filtered by referrer" do
        create(:visit, :google, url: "https://example.com/interesting")

        get "/visits.json", params: { visit_search: { referrer: "google" } }
        expect(response).to have_http_status(:success)

        parsed_body = response.parsed_body

        expect(parsed_body["summary"]).to eq({
                                               "avg_daily_visits" => 1,
                                               "total_visits" => 1,
                                               "median_daily_visits" => 1,
                                               "min_visits" => 1,
                                               "max_visits" => 1
                                             })

        expect(parsed_body["by_page"]).to eq([["https://example.com/interesting", 1]])
        expect(parsed_body["by_date"]).to eq([[Time.zone.today.to_s, 1]])
        expect(parsed_body["by_referrer"]).to eq([["https://www.google.com", 1]])
      end
    end

    describe "GET /visits/:id.json" do
      it "Returns visit details" do
        get "/visits/#{visit1.id}"
        expect(response).to have_http_status(:success)

        parsed_body = response.parsed_body
        expect(parsed_body["visits"]["id"]).to eq(visit1.id)
        expect(parsed_body["visits"]["guest_timezone_offset"]).to eq(visit1.guest_timezone_offset)
        expect(parsed_body["visits"]["user_agent"]).to eq(visit1.user_agent)
        expect(parsed_body["visits"]["remote_ip"]).to eq(visit1.remote_ip)
        expect(parsed_body["visits"]["referrer"]).to eq(visit1.referrer)
      end
    end
  end

  context "when not authenticated" do
    describe "POST /visits" do
      it "Records visit including IP address" do
        headers = {
          Accept: "application/json",
          "Content-Type": "application/json"
        }
        params = {
          guest_timezone_offset: 0,
          user_agent: Faker::Internet.user_agent,
          url: Faker::Internet.url(host: "example.com", scheme: "https"),
          referrer: "https://www.google.com/"
        }
        post "/visits", params: params.to_json, headers: headers
        expect(response).to have_http_status(:success)

        expect(Visit.last.guest_timezone_offset).to eq(0)
        expect(Visit.last.remote_ip).not_to be_nil
      end

      it "Does not record bot visits" do
        headers = {
          Accept: "application/json",
          "Content-Type": "application/json"
        }
        # rubocop:disable Layout/LineLength
        params = {
          guest_timezone_offset: 0,
          user_agent: "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36",
          url: Faker::Internet.url(host: "example.com", scheme: "https"),
          referrer: "https://www.google.com/"
        }
        # rubocop:enable Layout/LineLength
        post "/visits", params: params.to_json, headers: headers

        # by design, always return success response but no new visit should be recorded
        # 3 is from the initial setup
        expect(response).to have_http_status(:success)
        expect(Visit.count).to eq(3)
      end
    end
  end
end
