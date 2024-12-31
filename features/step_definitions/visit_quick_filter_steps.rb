# frozen_string_literal: true

When("I click the {string} quick filter") do |filter_name|
  click_on filter_name
end

Then("the {string} quick filter is active") do |filter_name|
  active_button = find("span", text: filter_name, class: "bg-indigo-100")
  expect(active_button).to be_present
end

Then("the {string} quick filter is not clickable") do |filter_name|
  expect(page).to have_no_link(filter_name)
end
