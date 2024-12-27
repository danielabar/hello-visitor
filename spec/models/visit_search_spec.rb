# frozen_string_literal: true

require "rails_helper"

RSpec.describe VisitSearch do
  describe "default attributes" do
    it "sets default url to an empty string" do
      visit_search = described_class.new
      expect(visit_search.url).to eq("")
    end

    it "sets default referrer to an empty string" do
      visit_search = described_class.new
      expect(visit_search.referrer).to eq("")
    end

    it "sets default start_date to 1 month ago" do
      visit_search = described_class.new
      expect(visit_search.start_date).to eq(1.month.ago.to_date)
    end

    it "sets default end_date to today" do
      visit_search = described_class.new
      expect(visit_search.end_date).to eq(Time.zone.today)
    end
  end

  describe "#start_datetime" do
    it "returns the beginning of the day for start_date" do
      visit_search = described_class.new(start_date: "2024-12-25")
      expect(visit_search.start_datetime).to eq(Date.parse("2024-12-25").beginning_of_day)
    end

    it "returns nil if start_date is nil" do
      visit_search = described_class.new(start_date: nil)
      expect(visit_search.start_datetime).to be_nil
    end
  end

  describe "#end_datetime" do
    it "returns the end of the day for end_date" do
      visit_search = described_class.new(end_date: "2024-12-25")
      expect(visit_search.end_datetime).to eq(Date.parse("2024-12-25").end_of_day)
    end

    it "returns nil if end_date is nil" do
      visit_search = described_class.new(end_date: nil)
      expect(visit_search.end_datetime).to be_nil
    end
  end
end
