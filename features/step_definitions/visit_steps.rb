# frozen_string_literal: true

Given("the following visits exist:") do |table|
  table.hashes.each do |visit|
    FactoryBot.create(:visit, visit)
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
