FactoryBot.define do
  factory :visit do
    guest_timezone_offset { 240 }
    user_agent { Faker::Internet.user_agent }
    url { Faker::Internet.url(host: 'example.com', scheme: 'https') }
    remote_ip { Faker::Internet.ip_v4_address }

    trait :google do
      referrer { 'https://www.google.com' }
    end

    trait :twitter do
      referrer { 'https://t.co' }
    end

    trait :random_referrer do
      referrer { Faker::Internet.url }
    end

    trait :google_bot do
      user_agent do
        # rubocop:disable Layout/LineLength
        'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36'
        # rubocop:enable Layout/LineLength
      end
    end
  end
end
