require 'rails_helper'

RSpec.describe Visit, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:guest_timezone_offset) }
    it { should validate_presence_of(:user_agent) }
    it { should validate_presence_of(:url) }

    describe 'not_a_bot' do
      it 'rejects bots' do
        visit = FactoryBot.build(:visit, :google_bot)
        expect(visit.valid?).to be(false)
        expect(visit.errors[:user_agent][0]).to eq('No bots allowed')
      end
    end
  end

  describe 'summary' do
    it 'Returns summary stats for last year' do
      FactoryBot.create_list(:visit, 20, created_at: 360.days.ago)
      FactoryBot.create_list(:visit, 2, created_at: 300.days.ago)
      FactoryBot.create_list(:visit, 6, created_at: 290.days.ago)

      result = Visit.summary

      expect(result[:min_visits]).to eq(2)
      expect(result[:max_visits]).to eq(20)
      expect(result[:total_visits]).to eq(28)
      expect(result[:avg_daily_visits]).to eq(9)
      expect(result[:median_daily_visits]).to eq(6)
    end

    it 'Returns summary stats for last week' do
      # these should all be ignored
      FactoryBot.create_list(:visit, 20, created_at: 360.days.ago)
      FactoryBot.create_list(:visit, 2, created_at: 300.days.ago)
      FactoryBot.create_list(:visit, 6, created_at: 290.days.ago)

      # these should be included
      FactoryBot.create_list(:visit, 10, created_at: 6.days.ago)
      FactoryBot.create_list(:visit, 5, created_at: 1.day.ago)

      result = Visit.summary(Time.zone.now - 7.days, Time.zone.now)

      expect(result[:min_visits]).to eq(5)
      expect(result[:max_visits]).to eq(10)
      expect(result[:total_visits]).to eq(15)
      expect(result[:avg_daily_visits]).to eq(8)
      expect(result[:median_daily_visits]).to eq(8)
    end
  end

  describe 'by_page' do
    it 'Returns an array of arrays in order of visit count, representing visits grouped by url' do
      FactoryBot.create(:visit, url: 'https://example.com/page1')
      FactoryBot.create(:visit, url: 'https://example.com/page1')
      FactoryBot.create(:visit, url: 'https://example.com/page2')

      result = Visit.by_page

      expect(result.length).to eq(2)

      expect(result[0][0]).to eq('https://example.com/page1')
      expect(result[0][1]).to eq(2)

      expect(result[1][0]).to eq('https://example.com/page2')
      expect(result[1][1]).to eq(1)
    end

    it 'Excludes visits from more than a year ago' do
      v = FactoryBot.create(:visit)
      FactoryBot.create(:visit, created_at: Time.zone.now - 13.months)

      result = Visit.by_page

      expect(result.length).to eq(1)
      expect(result[0][0]).to eq(v.url)
      expect(result[0][1]).to eq(1)
    end

    it 'Limits to 15 groups' do
      FactoryBot.create_list(:visit, 20)
      result = Visit.by_page
      expect(result.length).to eq(15)
    end
  end

  describe 'by_referrer' do
    it 'Returns an array of arrays in order of visit count, representing visits grouped by referrer' do
      FactoryBot.create(:visit, url: 'https://example.com/page1', referrer: 'https://www.google.com')
      FactoryBot.create(:visit, url: 'https://example.com/page2', referrer: 'https://www.google.com')
      FactoryBot.create(:visit, url: 'https://example.com/page3', referrer: 'https://www.linkedin.com')

      result = Visit.by_referrer

      expect(result.length).to eq(2)

      expect(result[0][0]).to eq('https://www.google.com')
      expect(result[0][1]).to eq(2)

      expect(result[1][0]).to eq('https://www.linkedin.com')
      expect(result[1][1]).to eq(1)
    end

    it 'Does not count visits with no referrer' do
      FactoryBot.create_list(:visit, 10)
      result = Visit.by_referrer
      expect(result).to eq([])
    end

    it 'Limits to 15 groups' do
      FactoryBot.create_list(:visit, 20, :random_referrer)
      result = Visit.by_referrer
      expect(result.length).to eq(15)
    end
  end

  describe 'by_date' do
    it 'Returns an array of arrays by date order, representing visits grouped by date' do
      visit1 = FactoryBot.create(:visit, url: 'https://example.com/page1', created_at: Time.zone.now - 5.days)
      visit2 = FactoryBot.create(:visit, url: 'https://example.com/page1', created_at: Time.zone.now - 1.day)
      FactoryBot.create(:visit, url: 'https://example.com/page2', created_at: Time.zone.now - 1.day)

      result = Visit.by_date

      expect(result.length).to eq(2)

      expect(result[0][0]).to eq(visit1.created_at.strftime('%Y-%m-%d'))
      expect(result[0][1]).to eq(1)
      expect(result[1][0]).to eq(visit2.created_at.strftime('%Y-%m-%d'))
      expect(result[1][1]).to eq(2)
    end
  end
end
