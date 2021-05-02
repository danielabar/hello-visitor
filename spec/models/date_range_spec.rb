require 'rails_helper'

RSpec.describe DateRange, type: :model do
  describe 'initialize' do
    it 'Uses parsed versions of given date strings' do
      today = Time.zone.now
      start_date = (today - 30.days).to_s(Time::DATE_FORMATS[:db])
      end_date = today.to_s(Time::DATE_FORMATS[:db])

      date_range = DateRange.new(start_date, end_date)

      expect(date_range.start_date.to_s(Time::DATE_FORMATS[:db])).to eq(start_date)
      expect(date_range.end_date.to_s(Time::DATE_FORMATS[:db])).to eq(end_date)
    end

    it 'Defaults to one year range if not given any start/end date strings' do
      date_range = DateRange.new(nil, nil)

      expect(date_range.start_date.to_s(Time::DATE_FORMATS[:short]))
        .to eq((Time.zone.now - 1.year).to_s(Time::DATE_FORMATS[:short]))
      expect(date_range.end_date.to_s(Time::DATE_FORMATS[:short]))
        .to eq((Time.zone.now).to_s(Time::DATE_FORMATS[:short]))
    end

    it 'Defaults to one year range if given invalid start/end date strings' do
      date_range = DateRange.new('foo', 'bar')

      expect(date_range.start_date.to_s(Time::DATE_FORMATS[:short]))
        .to eq((Time.zone.now - 1.year).to_s(Time::DATE_FORMATS[:short]))
      expect(date_range.end_date.to_s(Time::DATE_FORMATS[:short]))
        .to eq((Time.zone.now).to_s(Time::DATE_FORMATS[:short]))
    end
  end

  describe 'num_days' do
    it 'Calculates number of days between date range' do
      today = Time.zone.now
      start_date = (today - 7.days).to_s(Time::DATE_FORMATS[:db])
      end_date = today.to_s(Time::DATE_FORMATS[:db])

      date_range = DateRange.new(start_date, end_date)
      num_days = date_range.num_days

      expect(num_days).to eq(7)
    end

    it 'Calculates default 365 days when not given any start/end date strings' do
      date_range = DateRange.new(nil, nil)
      num_days = date_range.num_days

      expect(num_days).to eq(365)
    end

    it 'Calculates default 365 days when given invalid start/end date strings' do
      date_range = DateRange.new('foo', 'bar')
      num_days = date_range.num_days

      expect(num_days).to eq(365)
    end
  end
end
