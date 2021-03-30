require 'rails_helper'

RSpec.describe Visit, type: :model do
  describe 'total_visits' do
    it 'Returns count of visits within the last year' do
      FactoryBot.create_list(:visit, 10)
      FactoryBot.create_list(:visit, 5, created_at: Time.zone.now - 2.years)

      expect(Visit.total_visits).to eq(10)
    end
  end

  describe 'by_page' do
    it 'Returns an array of StatsItems in order of page count, representing visits grouped by url' do
      FactoryBot.create(:visit, url: 'https://example.com/page1')
      FactoryBot.create(:visit, url: 'https://example.com/page1')
      FactoryBot.create(:visit, url: 'https://example.com/page2')
      total_visits = 3

      result = Visit.by_page(total_visits)

      expect(result.length).to eq(2)

      expect(result[0].value).to eq('https://example.com/page1')
      expect(result[0].count).to eq(2)

      expect(result[1].value).to eq('https://example.com/page2')
      expect(result[1].count).to eq(1)
    end

    it 'Excludes visits from more than a year ago' do
      v = FactoryBot.create(:visit)
      FactoryBot.create(:visit, created_at: Time.zone.now - 13.months)
      total_visits = 2

      result = Visit.by_page(total_visits)

      expect(result.length).to eq(1)
      expect(result[0].value).to eq(v.url)
      expect(result[0].count).to eq(1)
    end
  end
end
