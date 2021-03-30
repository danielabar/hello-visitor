FactoryBot.define do
  factory :visit do
    guest_timezone_offset { 240 }
    user_agent { Faker::Internet.user_agent }
    url { Faker::Internet.url(host: 'example.com', scheme: 'https') }
    remote_ip { Faker::Internet.ip_v4_address }
  end
end
