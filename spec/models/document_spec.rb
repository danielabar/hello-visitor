require 'rails_helper'

RSpec.describe Document, type: :model do
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

  describe 'search_doc' do
    it 'searches documents via full text search' do
      results = Document.search_doc('code')

      expect(results.length).to eq(2)
      expect(results[0].id).to eq(doc1.id)
      expect(results[1].id).to eq(doc2.id)
    end
  end

  describe 'to_api' do
    it 'returns a subset of fields' do
      expected_obj = {
        title: doc1.title,
        description: doc1.description,
        category: doc1.category,
        published_at: doc1.published_at,
        slug: doc1.slug
      }

      expect(doc1.to_api).to eq(expected_obj)
    end
  end
end
