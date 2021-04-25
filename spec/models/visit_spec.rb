require 'rails_helper'

RSpec.describe Visit, type: :model do
  describe 'summary' do
    it 'Returns summary stats' do
      FactoryBot.create_list(:visit, 20, created_at: 5.days.ago)
      FactoryBot.create_list(:visit, 2, created_at: 4.days.ago)
      FactoryBot.create_list(:visit, 6, created_at: 3.days.ago)

      result = Visit.summary

      expect(result[:min_visits]).to eq(2)
      expect(result[:max_visits]).to eq(20)
      expect(result[:total_visits]).to eq(28)
      expect(result[:avg_daily_visits]).to eq(9)
      expect(result[:median_daily_visits]).to eq(6)
    end
  end

  describe 'total_visits' do
    it 'Returns count of visits within the last year' do
      FactoryBot.create_list(:visit, 10)
      FactoryBot.create_list(:visit, 5, created_at: Time.zone.now - 2.years)

      expect(Visit.total_visits).to eq(10)
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
