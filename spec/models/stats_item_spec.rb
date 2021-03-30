require 'rails_helper'

RSpec.describe StatsItem, type: :model do
  describe 'percentage' do
    it 'Calculates percentage count of total' do
      value = 'page1'
      count = 3
      total = 10
      expect(StatsItem.new(value, count, total).percentage).to eq(0.3)
    end
  end
end
