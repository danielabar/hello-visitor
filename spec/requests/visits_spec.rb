require 'rails_helper'

RSpec.describe 'Visits', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let!(:visit1) { FactoryBot.create(:visit, url: 'https://example.com/page1', created_at: Time.zone.now - 5.days) }
  let!(:visit2) { FactoryBot.create(:visit, url: 'https://example.com/page1', created_at: Time.zone.now - 1.day) }
  let!(:visit3) { FactoryBot.create(:visit, url: 'https://example.com/page2', created_at: Time.zone.now - 1.day) }

  context 'Authenticated' do
    before(:each) do
      sign_in(user)
    end

    describe 'GET /visits.json' do
      it 'Returns all visits in the last year and some stats' do
        get '/visits.json'
        expect(response).to have_http_status(:success)

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['summary']['total_visits']).to eq(3)

        expect(parsed_body['by_page'][0][0]).to eq('https://example.com/page1')
        expect(parsed_body['by_page'][0][1]).to eq(2)
        expect(parsed_body['by_page'][1][0]).to eq('https://example.com/page2')
        expect(parsed_body['by_page'][1][1]).to eq(1)

        expect(parsed_body['by_date'][0][0]).to eq(visit1.created_at.strftime('%Y-%m-%d'))
        expect(parsed_body['by_date'][0][1]).to eq(1)
        expect(parsed_body['by_date'][1][0]).to eq(visit2.created_at.strftime('%Y-%m-%d'))
        expect(parsed_body['by_date'][1][1]).to eq(2)

        expect(parsed_body['by_referrer']).to eq([])
      end
    end

    describe 'GET /visits/:id.json' do
      it 'Returns visit details' do
        get "/visits/#{visit1.id}"
        expect(response).to have_http_status(:success)

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['visits']['id']).to eq(visit1.id)
        expect(parsed_body['visits']['guest_timezone_offset']).to eq(visit1.guest_timezone_offset)
        expect(parsed_body['visits']['user_agent']).to eq(visit1.user_agent)
        expect(parsed_body['visits']['remote_ip']).to eq(visit1.remote_ip)
        expect(parsed_body['visits']['referrer']).to eq(visit1.referrer)
      end
    end
  end

  context 'Not Authenticated' do
    describe 'POST /visits' do
      it 'Records visit including IP address' do
        headers = {
          Accept: 'application/json',
          'Content-Type': 'application/json'
        }
        params = {
          guest_timezone_offset: 0,
          user_agent: Faker::Internet.user_agent,
          url: Faker::Internet.url(host: 'example.com', scheme: 'https'),
          referrer: 'https://www.google.com/'
        }
        post '/visits', params: params.to_json, headers: headers
        expect(response).to have_http_status(:success)

        expect(Visit.last.guest_timezone_offset).to eq(0)
        expect(Visit.last.remote_ip).not_to be_nil
      end
    end
  end
end
