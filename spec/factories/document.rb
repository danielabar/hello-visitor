FactoryBot.define do
  factory :document do
    title { Faker::Book.title }
    description { Faker::Lorem.sentence(word_count: 5) }
    category { Faker::Book.genre }
    published_at { Faker::Date.backward(days: 14) }
    slug { Faker::Internet.slug }
    body { Faker::Lorem.paragraph(sentence_count: 3) }
    excerpt { Faker::Lorem.sentence(word_count: 10) }
  end
end
