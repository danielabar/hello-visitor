# frozen_string_literal: true

Given("the following visits exist:") do |table|
  table.hashes.each do |visit|
    FactoryBot.create(:visit, visit)
  end
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I click {string}") do |button|
  click_on button
  # debugger
end

Then("the URL should contain {string}") do |expected_part|
  expect(page.current_url).to include(expected_part)
end
