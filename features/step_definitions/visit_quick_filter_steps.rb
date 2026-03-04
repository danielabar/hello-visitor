# frozen_string_literal: true

When("I click the {string} quick filter") do |filter_name|
  click_on filter_name
end

Then("the {string} quick filter is active") do |filter_name|
  active_button = find("[data-test-id='quick-filter-active'][data-label='#{filter_name}']")
  expect(active_button).to be_present
end

Then("the {string} quick filter is not clickable") do |filter_name|
  expect(page).to have_no_link(filter_name)
end

Then("the {string} granularity toggle is active") do |label|
  active = find("[data-test-id='granularity-active'][data-label='#{label}']")
  expect(active).to be_present
end

Then("the {string} granularity toggle is not clickable") do |label|
  expect(page).to have_no_link(label, href: /granularity=#{label.downcase}/)
end

Then("the {string} granularity toggle is clickable") do |label|
  expect(page).to have_link(label)
end

When("I click the {string} granularity toggle") do |label|
  find("[data-test-id='granularity-link'][data-label='#{label}']").click
end
