require 'rails_helper'

RSpec.describe Document, type: :model do
  describe 'search_doc' do
    let!(:doc1) do
      FactoryBot.create(:document,
                        body: 'Any fool can write code that a computer can understand. \
                               Good programmers write code that humans can understand.')
    end
    let!(:doc2) do
      FactoryBot.create(:document, body: 'Talk is cheap. Show me the code.')
    end

    let!(:doc3) do
      FactoryBot.create(:document,
                        body: 'First learn computer science and all the theory. Next develop a programming style. \
                               Then forget all that and just hack.')
    end

    it 'searches documents via full text search' do
      results = Document.search_doc('code')

      expect(results.length).to eq(2)
      expect(results[0].id).to eq(doc1.id)
      expect(results[1].id).to eq(doc2.id)
    end
  end
end
