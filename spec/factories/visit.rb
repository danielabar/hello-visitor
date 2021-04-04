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
  end
end
