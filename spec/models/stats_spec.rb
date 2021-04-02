require 'rails_helper'

RSpec.describe Stats, type: :model do
  describe '#collect' do
    let!(:visit1) { FactoryBot.create(:visit, url: 'https://example.com/page1', created_at: Time.zone.now - 5.days) }
    let!(:visit2) { FactoryBot.create(:visit, url: 'https://example.com/page1', created_at: Time.zone.now - 1.day) }
    let!(:visit3) { FactoryBot.create(:visit, url: 'https://example.com/page2', created_at: Time.zone.now - 1.day) }

    it 'Calculates some visit stats' do
      stats = Stats.new(Time.zone.now, Time.zone.now - 1.year)
      stats.collect

      expect(stats.total_visits).to eq(3)

      expect(stats.by_page[0][0]).to eq('https://example.com/page1')
      expect(stats.by_page[0][1]).to eq(2)
      expect(stats.by_page[1][0]).to eq('https://example.com/page2')
      expect(stats.by_page[1][1]).to eq(1)

      expect(stats.by_date[0][0]).to eq(visit1.created_at.strftime('%Y-%m-%d'))
      expect(stats.by_date[0][1]).to eq(1)
      expect(stats.by_date[1][0]).to eq(visit2.created_at.strftime('%Y-%m-%d'))
      expect(stats.by_date[1][1]).to eq(2)
    end
  end
end
