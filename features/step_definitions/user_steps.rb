# frozen_string_literal: true

Given("a user exists with email {string} and password {string}") do |email, password|
  FactoryBot.create(:user, email: email, password: password)
end

Given("I am logged in as {string} with password {string}") do |email, password|
  visit new_user_session_path
  fill_in "Email", with: email
  fill_in "Password", with: password
  click_on "Log in"
  # debugger
end

When("I visit the login page") do
  visit new_user_session_path
  # debugger
  # page.driver.debug(binding)
end

When("I visit the visits dashboard page") do
  visit visits_path
end

When("I visit the about page") do
  visit about_path
end

Then("I should see {string}") do |content|
  expect(page).to have_content(content)
end

# And(/^I should see the "([^"]*)" section$/) do |section_name|
#   expect(page).to have_content(section_name)
# end

Then("I should not see {string}") do |content|
  expect(page).to have_no_content(content)
end

Then("I should be redirected to the login page") do
  expect(page).to have_current_path(new_user_session_path)
end
