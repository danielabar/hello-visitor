# frozen_string_literal: true

Given("a user exists with email {string} and password {string}") do |email, password|
  FactoryBot.create(:user, email: email, password: password)
end

When("I submit the login form with {string} and {string}") do |email, password|
  fill_in "Email", with: email
  fill_in "Password", with: password
  click_on "Log in"
end

Then("I should be signed in") do
  expect(page).to have_current_path(root_path)
  expect(page).to have_css('[role="alert"]', text: "Signed in successfully.")
end

Then("I should not be signed in") do
  expect(page).to have_current_path(new_user_session_path)
  expect(page).to have_css('[role="alert"]', text: "Invalid Email or password.")
end

When("I am logged in as any user") do
  visit(new_user_session_path)

  user = FactoryBot.create(:user)
  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_on "Log in"

  expect(page).to have_current_path(root_path)
  expect(page).to have_css('[role="alert"]', text: "Signed in successfully.")
end
