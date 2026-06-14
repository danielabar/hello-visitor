# frozen_string_literal: true

require "rails_helper"

RSpec.describe IncomingVisit do
  describe "#build" do
    subject(:visit) { described_class.new(params: params, remote_ip: remote_ip).build }

    let(:params) do
      {
        guest_timezone_offset: 240,
        user_agent: "Mozilla/5.0",
        url: "https://example.com/page",
        referrer: "https://www.google.de/"
      }
    end
    let(:remote_ip) { "203.0.113.42" }

    it "returns an unsaved Visit" do
      expect(visit).to be_a(Visit)
      expect(visit).not_to be_persisted
    end

    it "assigns the remote IP from the request" do
      expect(visit.remote_ip).to eq(remote_ip)
    end

    it "derives referrer_group via ReferrerNormalizer" do
      expect(visit.referrer_group).to eq("Google")
    end

    it "leaves referrer_group nil when referrer is blank" do
      params[:referrer] = ""
      expect(visit.referrer_group).to be_nil
    end

    it "sanitizes the user_agent field" do
      params[:user_agent] = "<script>alert('xss')</script>Mozilla"
      expect(visit.user_agent).not_to include("<script>")
    end

    it "sanitizes the url field" do
      params[:url] = "<script>alert('xss')</script>https://example.com"
      expect(visit.url).not_to include("<script>")
    end

    it "passes through visit_params attributes" do
      expect(visit.guest_timezone_offset).to eq(240)
    end
  end
end
