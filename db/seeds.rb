# frozen_string_literal: true

return unless Rails.env.development?

my_logger = Logger.new($stdout)
my_logger.info "Initialized stdout logger for seeds"

TIMEZONE_OFFSETS = [
  420,
  -120,
  -420,
  -180,
  -330,
  240,
  300
].freeze

# PAGES = [
#   "blog/doc1",
#   "blog/doc2",
#   "blog/doc3",
#   "blog/doc4",
#   "blog/doc5"
# ].freeze
PAGES = (1..100).map { |i| "blog/doc#{i}" }.freeze

REFERRERS = [
  "https://www.google.com",
  "https://www.twitter.com",
  "https://www.facebook.com",
  "https://www.linkedin.com"
].freeze

def assign_url
  favor_first_docs = Faker::Boolean.boolean(true_ratio: 0.7)
  if favor_first_docs
    "https://example.com/#{PAGES[Faker::Number.between(from: 0, to: 1)]}"
  else
    "https://example.com/#{PAGES[Faker::Number.between(from: 0, to: PAGES.length - 1)]}"
  end
end

def assign_visit_date
  favor_recent_months = Faker::Boolean.boolean(true_ratio: 0.7)
  if favor_recent_months
    Faker::Date.between(from: 5.months.ago, to: Time.zone.today)
  else
    Faker::Date.between(from: 1.year.ago, to: Time.zone.today)
  end
end

my_logger.info("Creating user...")
User.destroy_all
user = User.new({ email: "test@example.com", password: "password", password_confirmation: "password" })
user.save!

my_logger.info("Creating visits...")
Visit.destroy_all
1000.times do |_|
  visit_date = assign_visit_date
  with_referrer = Faker::Boolean.boolean(true_ratio: 0.6) # rubocop:disable Rails/ThreeStateBooleanColumn
  visit = Visit.new(
    {
      guest_timezone_offset: TIMEZONE_OFFSETS[Faker::Number.between(from: 0, to: TIMEZONE_OFFSETS.length - 1)],
      user_agent: Faker::Internet.user_agent,
      url: assign_url,
      remote_ip: Faker::Internet.ip_v4_address,
      referrer: with_referrer ? REFERRERS[Faker::Number.between(from: 0, to: REFERRERS.length - 1)] : nil,
      created_at: visit_date,
      updated_at: visit_date
    }
  )
  visit.save!
end
