# frozen_string_literal: true

require "rails_helper"

RSpec.describe DateRange do
  describe "initialize" do
    it "Uses parsed versions of given date strings" do
      today = Time.zone.now
      start_date = (today - 30.days).strftime(Time::DATE_FORMATS[:db])
      end_date = today.strftime(Time::DATE_FORMATS[:db])

      date_range = described_class.new(start_date, end_date)

      expect(date_range.start_date.strftime(Time::DATE_FORMATS[:db])).to eq(start_date)
      expect(date_range.end_date.strftime(Time::DATE_FORMATS[:db])).to eq(end_date)
    end

    it "Defaults to one year range if not given any start/end date strings" do
      date_range = described_class.new(nil, nil)

      expect(date_range.start_date.strftime(Time::DATE_FORMATS[:short]))
        .to eq(1.year.ago.strftime(Time::DATE_FORMATS[:short]))
      expect(date_range.end_date.strftime(Time::DATE_FORMATS[:short]))
        .to eq(Time.zone.now.strftime(Time::DATE_FORMATS[:short]))
    end

    it "Defaults to one year range if given invalid start/end date strings" do
      date_range = described_class.new("foo", "bar")

      expect(date_range.start_date.strftime(Time::DATE_FORMATS[:short]))
        .to eq(1.year.ago.strftime(Time::DATE_FORMATS[:short]))
      expect(date_range.end_date.strftime(Time::DATE_FORMATS[:short]))
        .to eq(Time.zone.now.strftime(Time::DATE_FORMATS[:short]))
    end
  end

  describe "num_days" do
    it "Calculates number of days between date range" do
      today = Time.zone.now
      start_date = (today - 7.days).strftime(Time::DATE_FORMATS[:db])
      end_date = today.strftime(Time::DATE_FORMATS[:db])

      date_range = described_class.new(start_date, end_date)
      num_days = date_range.num_days

      expect(num_days).to eq(7)
    end

    it "Calculates the correct number of days for the default date range when no dates are provided" do
      date_range = described_class.new(nil, nil)
      num_days = date_range.num_days

      expected_days = (Time.zone.now.to_date - 1.year.ago.to_date).to_i
      expect(num_days).to eq(expected_days)
    end

    it "Calculates the correct number of days for the default date range when invalid dates are provided" do
      date_range = described_class.new("foo", "bar")
      num_days = date_range.num_days

      expected_days = (Time.zone.now.to_date - 1.year.ago.to_date).to_i
      expect(num_days).to eq(expected_days)
    end
  end
end
