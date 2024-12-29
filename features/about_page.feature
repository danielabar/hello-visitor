Feature: About Page
  As any user
  I want to view the About page
  So that I can learn more about the application.

  Scenario: Visit the About page as an unauthenticated user
    Given I visit the about page
    Then I should see "About"
    And I should see "your free and privacy-focused analytics solution"

  Scenario: Visit the About page as an authenticated user
    Given I am logged in as "user@example.com" with password "password"
    And I visit the about page
    Then I should see "About"
    And I should see "your free and privacy-focused analytics solution"
