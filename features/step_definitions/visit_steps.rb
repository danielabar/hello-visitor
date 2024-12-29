# frozen_string_literal: true

Given("the following visits exist:") do |table|
  table.hashes.each do |visit|
    visit["created_at"] = parse_dynamic_date(visit["created_at"]) if visit["created_at"].present?
    FactoryBot.create(:visit, visit)
  end
end

Then("the Summary section shows stats:") do |table|
  stats = table.hashes[0]

  stats.each do |label, expected_value|
    element = find("[data-test-id='stat-#{label.parameterize}']")
    expect(element.text.strip).to eq(expected_value)
  end
end

When("I search by content {string}") do |content|
  fill_in "Content", with: content
  click_on "Search"
end

When("I search by referrer {string}") do |referrer|
  fill_in "Referrer", with: referrer
  click_on "Search"
end

When("I search by date range from {string} to {string}") do |start_date, end_date|
  fill_in "Start date", with: start_date
  fill_in "End date", with: end_date
  click_on "Search"
end

Then("the URL should contain {string}") do |expected_part|
  expect(page.current_url).to include(expected_part)
end

def parse_dynamic_date(value)
  case value
  when /\A(\d+)\.days?\.ago\z/
    Regexp.last_match(1).to_i.days.ago
  when /\A(\d+)\.weeks?\.ago\z/
    Regexp.last_match(1).to_i.weeks.ago
  when /\A(\d+)\.months?\.ago\z/
    Regexp.last_match(1).to_i.months.ago
  else
    raise ArgumentError, "Unsupported dynamic date format: #{value}"
  end
end
