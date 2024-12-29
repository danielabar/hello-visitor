# frozen_string_literal: true

When("I visit the root path") do
  visit root_path
end

Then("I should be redirected to the login page") do
  expect(page).to have_current_path(new_user_session_path)
  expect(page).to have_css('[role="alert"]', text: "You need to sign in or sign up before continuing.")
end

When("I visit the About page") do
  visit about_path
end
