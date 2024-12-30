# frozen_string_literal: true

Then("I should see About page content") do
  expect(page).to have_content("your free and privacy-focused analytics solution")
end
