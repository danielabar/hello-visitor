# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search" do
  let!(:doc1) do
    create(:document,
           title: "Programming Quote 1",
           body: 'Any fool can write code that a computer can understand. \
                             Good programmers write code that humans can understand.')
  end

  let!(:doc2) do
    create(:document, title: "Programming Quote 2", body: "Talk is cheap. Show me the code.")
  end

  let!(:doc3) do
    create(:document,
           title: "Programming Quote 3",
           body: 'First learn computer science and all the theory. Next develop a programming style. \
                             Then forget all that and just hack.')
  end

  let(:headers) do
    {
      Accept: "application/json"
    }
  end

  describe "GET /search" do
    it "Returns search results for query `code`" do
      get "/search?q=code", headers: headers

      expect(response).to have_http_status(:success)

      parsed_body = response.parsed_body
      expect(parsed_body.length).to eq(2)
      expect(parsed_body[0]["title"]).to eq(doc1.title)
      expect(parsed_body[1]["title"]).to eq(doc2.title)
    end

    it "Returns results matching `programming` when not given a query" do
      get "/search", headers: headers

      expect(response).to have_http_status(:success)

      parsed_body = response.parsed_body
      expect(parsed_body.length).to eq(3)
      expect(parsed_body[0]["title"]).to eq(doc3.title)
      expect(parsed_body[1]["title"]).to eq(doc1.title)
      expect(parsed_body[2]["title"]).to eq(doc2.title)
    end

    it "Returns empty array when nothing matches" do
      get "/search?q=zzzzzzzzzzzzz", headers: headers

      expect(response).to have_http_status(:success)

      parsed_body = response.parsed_body
      expect(parsed_body).to eq([])
    end
  end
end
