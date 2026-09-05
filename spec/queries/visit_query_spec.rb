# frozen_string_literal: true

require "rails_helper"

RSpec.describe VisitQuery do
  let(:default_search) { VisitSearch.new }

  describe ".summary" do
    it "returns correct aggregate values for the date range" do
      create_list(:visit, 10, created_at: 60.days.ago)
      create_list(:visit, 2, created_at: 30.days.ago)
      create_list(:visit, 6, created_at: 10.days.ago)

      visit_search = VisitSearch.new(start_date: 90.days.ago.to_date)
      result = described_class.summary(visit_search)

      expect(result[0]["total_visits"]).to eq(18)
      expect(result[0]["min_visits"]).to eq(2)
      expect(result[0]["max_visits"]).to eq(10)
      expect(result[0]["avg_daily_visits"]).to eq(6)
      expect(result[0]["median_daily_visits"]).to eq(6)
    end

    it "excludes visits outside the date range" do
      create_list(:visit, 5, created_at: 2.days.ago)
      create_list(:visit, 10, created_at: 400.days.ago)

      visit_search = VisitSearch.new(start_date: 7.days.ago.to_date)
      result = described_class.summary(visit_search)

      expect(result[0]["total_visits"]).to eq(5)
    end

    it "filters by url (LIKE)" do
      create(:visit, url: "https://example.com/page1")
      create(:visit, url: "https://example.com/page1")
      create(:visit, url: "https://example.com/about")

      visit_search = VisitSearch.new(url: "page1")
      result = described_class.summary(visit_search)

      expect(result[0]["total_visits"]).to eq(2)
    end

    it "filters by referrer case-insensitively (ILIKE)" do
      create(:visit, referrer: "https://www.Google.com")
      create(:visit, referrer: "https://www.google.com")
      create(:visit, referrer: "https://www.bing.com")

      visit_search = VisitSearch.new(referrer: "google")
      result = described_class.summary(visit_search)

      expect(result[0]["total_visits"]).to eq(2)
    end
  end

  describe ".by_page" do
    it "returns results ordered by count DESC" do
      create(:visit, url: "https://example.com/page1")
      create(:visit, url: "https://example.com/page2")
      create(:visit, url: "https://example.com/page2")

      result = described_class.by_page(default_search)

      expect(result[0]["just_url"]).to eq("https://example.com/page2")
      expect(result[0]["page_count"]).to eq(2)
      expect(result[1]["just_url"]).to eq("https://example.com/page1")
      expect(result[1]["page_count"]).to eq(1)
    end

    it "strips query string from URL via SPLIT_PART" do
      create(:visit, url: "https://example.com/page?foo=bar")
      create(:visit, url: "https://example.com/page?baz=1")

      result = described_class.by_page(default_search)

      expect(result.length).to eq(1)
      expect(result[0]["just_url"]).to eq("https://example.com/page")
      expect(result[0]["page_count"]).to eq(2)
    end

    it "filters by url" do
      create(:visit, url: "https://example.com/page1")
      create(:visit, url: "https://example.com/about")

      visit_search = VisitSearch.new(url: "page1")
      result = described_class.by_page(visit_search)

      expect(result.length).to eq(1)
      expect(result[0]["just_url"]).to eq("https://example.com/page1")
    end

    it "excludes visits outside the date range" do
      create(:visit, url: "https://example.com/page1", created_at: 2.days.ago)
      create(:visit, url: "https://example.com/page1", created_at: 400.days.ago)

      visit_search = VisitSearch.new(start_date: 7.days.ago.to_date)
      result = described_class.by_page(visit_search)

      expect(result.length).to eq(1)
      expect(result[0]["page_count"]).to eq(1)
    end

    it "limits to MAX_GROUPS (10) records" do
      11.times { |i| create(:visit, url: "https://example.com/page#{i}") }

      result = described_class.by_page(default_search)

      expect(result.length).to eq(VisitQuery::MAX_GROUPS)
    end
  end

  describe ".by_page_bottom" do
    it "returns results ordered by count ASC" do
      create(:visit, url: "https://example.com/page1")
      create(:visit, url: "https://example.com/page2")
      create(:visit, url: "https://example.com/page2")

      result = described_class.by_page_bottom(default_search)

      expect(result[0]["just_url"]).to eq("https://example.com/page1")
      expect(result[0]["page_count"]).to eq(1)
      expect(result[1]["just_url"]).to eq("https://example.com/page2")
      expect(result[1]["page_count"]).to eq(2)
    end

    it "limits to MAX_GROUPS_BOTTOM (5) records" do
      10.times { |i| create(:visit, url: "https://example.com/page#{i}") }

      result = described_class.by_page_bottom(default_search)

      expect(result.length).to eq(VisitQuery::MAX_GROUPS_BOTTOM)
    end

    it "filters by url" do
      create(:visit, url: "https://example.com/page1")
      create(:visit, url: "https://example.com/about")

      visit_search = VisitSearch.new(url: "page1")
      result = described_class.by_page_bottom(visit_search)

      expect(result.length).to eq(1)
      expect(result[0]["just_url"]).to eq("https://example.com/page1")
    end

    it "excludes visits outside the date range" do
      create(:visit, url: "https://example.com/page1", created_at: 2.days.ago)
      create(:visit, url: "https://example.com/page1", created_at: 400.days.ago)

      visit_search = VisitSearch.new(start_date: 7.days.ago.to_date)
      result = described_class.by_page_bottom(visit_search)

      expect(result.length).to eq(1)
      expect(result[0]["page_count"]).to eq(1)
    end

    it "returns the least-visited URLs (different from by_page when more than MAX_GROUPS_BOTTOM URLs exist)" do
      # page0: 1 visit, page1: 2, page2: 3, page3: 4, page4: 5, page5: 6
      6.times { |i| create_list(:visit, i + 1, url: "https://example.com/page#{i}") }

      top = described_class.by_page(default_search)
      bottom = described_class.by_page_bottom(default_search)

      expect(top[0]["just_url"]).to include("page5") # most visited
      expect(bottom[0]["just_url"]).to include("page0") # least visited
    end
  end

  describe ".by_referrer" do
    it "groups by referrer_group and orders by count DESC" do
      create_list(:visit, 5, referrer_group: "Google")
      create_list(:visit, 3, referrer_group: "Reddit")
      create(:visit, referrer_group: "Hacker News")

      result = described_class.by_referrer(default_search)

      expect(result[0]["referrer"]).to     eq("Google")
      expect(result[0]["visit_count"]).to  eq(5)
      expect(result[1]["referrer"]).to     eq("Reddit")
      expect(result[1]["visit_count"]).to  eq(3)
      expect(result[2]["referrer"]).to     eq("Hacker News")
      expect(result[2]["visit_count"]).to  eq(1)
    end

    it "excludes visits with NULL referrer_group (direct visits)" do
      create_list(:visit, 5, referrer_group: nil)
      create(:visit, referrer_group: "Google")

      result = described_class.by_referrer(default_search)

      expect(result.length).to eq(1)
      expect(result[0]["referrer"]).to eq("Google")
    end

    it "excludes 'self' referrer_group (internal nav)" do
      create_list(:visit, 5, referrer_group: "self")
      create(:visit, referrer_group: "Google")

      result = described_class.by_referrer(default_search)

      expect(result.length).to eq(1)
      expect(result[0]["referrer"]).to eq("Google")
    end

    it "filters by url" do
      create(:visit, url: "https://example.com/page1", referrer_group: "Google")
      create(:visit, url: "https://example.com/about", referrer_group: "Bing")

      visit_search = VisitSearch.new(url: "page1")
      result = described_class.by_referrer(visit_search)

      expect(result.length).to eq(1)
      expect(result[0]["referrer"]).to eq("Google")
    end

    it "filters by raw referrer (search box ILIKE on the raw column)" do
      create(:visit, referrer: "https://www.google.com", referrer_group: "Google")
      create(:visit, referrer: "https://www.bing.com",   referrer_group: "Bing")

      visit_search = VisitSearch.new(referrer: "google")
      result = described_class.by_referrer(visit_search)

      expect(result.length).to eq(1)
      expect(result[0]["referrer"]).to eq("Google")
    end

    it "excludes visits outside the date range" do
      create(:visit, referrer_group: "Google", created_at: 2.days.ago)
      create(:visit, referrer_group: "Google", created_at: 400.days.ago)

      visit_search = VisitSearch.new(start_date: 7.days.ago.to_date)
      result = described_class.by_referrer(visit_search)

      expect(result[0]["visit_count"]).to eq(1)
    end

    it "limits to MAX_GROUPS (10) records" do
      11.times { |i| create(:visit, referrer_group: "group-#{i}") }

      result = described_class.by_referrer(default_search)

      expect(result.length).to eq(VisitQuery::MAX_GROUPS)
    end
  end

  describe ".by_date" do
    it "returns results ordered by date ASC" do
      create(:visit, created_at: 5.days.ago)
      create(:visit, created_at: 1.day.ago)

      result = described_class.by_date(default_search)

      expect(result.length).to eq(2)
      expect(result[0]["visit_date"]).to be < result[1]["visit_date"]
    end

    it "groups multiple visits on the same day into one row" do
      create(:visit, created_at: 2.days.ago)
      create(:visit, created_at: 2.days.ago)
      create(:visit, created_at: 1.day.ago)

      result = described_class.by_date(default_search)

      expect(result.length).to eq(2)
      expect(result[0]["visit_count"]).to eq(2)
      expect(result[1]["visit_count"]).to eq(1)
    end

    it "excludes visits outside the date range" do
      create(:visit, created_at: 2.days.ago)
      create(:visit, created_at: 400.days.ago)

      visit_search = VisitSearch.new(start_date: 7.days.ago.to_date)
      result = described_class.by_date(visit_search)

      expect(result.length).to eq(1)
    end

    it "filters by url" do
      create(:visit, url: "https://example.com/page1", created_at: 1.day.ago)
      create(:visit, url: "https://example.com/about", created_at: 1.day.ago)

      visit_search = VisitSearch.new(url: "page1")
      result = described_class.by_date(visit_search)

      expect(result.length).to eq(1)
      expect(result[0]["visit_count"]).to eq(1)
    end
  end

  describe ".by_month" do
    it "returns results ordered by month ASC" do
      create_list(:visit, 3, created_at: 40.days.ago)
      create_list(:visit, 5, created_at: 5.days.ago)

      visit_search = VisitSearch.new(start_date: 2.months.ago.to_date)
      result = described_class.by_month(visit_search)

      expect(result.length).to eq(2)
      expect(result[0]["visit_month"]).to be < result[1]["visit_month"]
    end

    it "groups visits in the same month into one row" do
      create_list(:visit, 4, created_at: 40.days.ago)

      visit_search = VisitSearch.new(start_date: 2.months.ago.to_date)
      result = described_class.by_month(visit_search)

      expect(result.length).to eq(1)
      expect(result[0]["visit_count"]).to eq(4)
    end

    it "excludes visits outside the date range" do
      create_list(:visit, 3, created_at: 5.days.ago)
      create_list(:visit, 5, created_at: 400.days.ago)

      visit_search = VisitSearch.new(start_date: 30.days.ago.to_date)
      result = described_class.by_month(visit_search)

      expect(result.length).to eq(1)
      expect(result[0]["visit_count"]).to eq(3)
    end
  end

  describe ".monthly_summary" do
    it "returns correct aggregate values by month" do
      create_list(:visit, 3, created_at: 40.days.ago)
      create_list(:visit, 5, created_at: 5.days.ago)

      visit_search = VisitSearch.new(start_date: 2.months.ago.to_date, granularity: "month")
      result = described_class.monthly_summary(visit_search)

      expect(result[0]["total_visits"]).to eq(8)
      expect(result[0]["min_visits"]).to eq(3)
      expect(result[0]["max_visits"]).to eq(5)
      expect(result[0]["avg_monthly_visits"]).to eq(4)
      expect(result[0]["median_monthly_visits"]).to eq(4)
    end

    it "excludes visits outside the date range" do
      create_list(:visit, 3, created_at: 5.days.ago)
      create_list(:visit, 5, created_at: 400.days.ago)

      visit_search = VisitSearch.new(start_date: 30.days.ago.to_date, granularity: "month")
      result = described_class.monthly_summary(visit_search)

      expect(result[0]["total_visits"]).to eq(3)
    end
  end
end
