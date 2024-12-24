# frozen_string_literal: true

require "rails_helper"

RSpec.describe Document do
  let!(:doc1) do
    create(:document,
           title: "Code for Humans",
           body: 'Any fool can write code that a computer can understand. \
                             Good programmers write code that humans can understand.')
  end

  let!(:doc2) do
    create(:document,
           title: "Show Me the Code",
           body: "Talk is cheap. Show me the code.")
  end

  let!(:doc3) do
    create(:document,
           title: "Hack Away",
           body: 'First learn computer science and all the theory. Next develop a programming style. \
                             Then forget all that and just hack.')
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
  end

  describe "search_doc" do
    it "searches documents via full text search" do
      results = described_class.search_doc("code")

      expect(results.length).to eq(2)
      expect(results[0].id).to eq(doc1.id)
      expect(results[1].id).to eq(doc2.id)
    end
  end

  describe "search" do
    it "searches and converts results to api format" do
      expect(Rails.logger).to receive(:info).with(/Search: query = code, num results = 2/).and_call_original
      results = described_class.search("code")

      expect(results.length).to eq(2)
      expect(results[0]).to eq(doc1.to_api)
      expect(results[1]).to eq(doc2.to_api)
    end
  end

  describe "to_api" do
    it "returns a subset of fields" do
      expected_obj = {
        title: doc1.title,
        description: doc1.description,
        category: doc1.category,
        published_at: doc1.published_at,
        slug: doc1.slug,
        excerpt: doc1.excerpt
      }

      expect(doc1.to_api).to eq(expected_obj)
    end
  end
end
