# frozen_string_literal: true

require "rails_helper"

RSpec.describe Stats do
  describe "#collect" do
    let!(:visit1) { create(:visit, :google, url: "https://ex.com/p1", created_at: 5.days.ago) }
    let!(:visit2) { create(:visit, :twitter, url: "https://ex.com/p1", created_at: 1.day.ago) }
    let!(:visit3) { create(:visit, :twitter, url: "https://ex.com/p2", created_at: 1.day.ago) }

    it "Collects some visit stats from the Visits model" do
      stats = described_class.new(1.year.ago, Time.zone.now, "")
      stats.collect

      expect(stats.summary[:min_visits]).to eq(1)
      expect(stats.summary[:max_visits]).to eq(2)
      expect(stats.summary[:avg_daily_visits]).to eq(2)
      expect(stats.summary[:median_daily_visits]).to eq(2)

      expect(stats.by_page[0][0]).to eq("https://ex.com/p1")
      expect(stats.by_page[0][1]).to eq(2)
      expect(stats.by_page[1][0]).to eq("https://ex.com/p2")
      expect(stats.by_page[1][1]).to eq(1)

      expect(stats.by_date[0][0]).to eq(visit1.created_at.strftime("%Y-%m-%d"))
      expect(stats.by_date[0][1]).to eq(1)
      expect(stats.by_date[1][0]).to eq(visit2.created_at.strftime("%Y-%m-%d"))
      expect(stats.by_date[1][1]).to eq(2)

      expect(stats.by_referrer[0][0]).to eq("https://t.co")
      expect(stats.by_referrer[0][1]).to eq(2)
      expect(stats.by_referrer[1][0]).to eq("https://www.google.com")
      expect(stats.by_referrer[1][1]).to eq(1)
    end

    it "Filters by given url" do
      url = "p2"
      stats = described_class.new(1.year.ago, Time.zone.now, url)
      stats.collect

      expect(stats.summary[:min_visits]).to eq(1)
      expect(stats.summary[:max_visits]).to eq(1)
      expect(stats.summary[:avg_daily_visits]).to eq(1)
      expect(stats.summary[:median_daily_visits]).to eq(1)

      expect(stats.by_page[0][0]).to eq("https://ex.com/p2")
      expect(stats.by_page[0][1]).to eq(1)

      expect(stats.by_date[0][0]).to eq(visit3.created_at.strftime("%Y-%m-%d"))
      expect(stats.by_date[0][1]).to eq(1)

      expect(stats.by_referrer[0][0]).to eq("https://t.co")
      expect(stats.by_referrer[0][1]).to eq(1)
    end
  end
end
