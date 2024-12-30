@javascript
Feature: About Page

  Background:
    Given a user exists with email "user@example.com" and password "password"

  Scenario: Visit the About page as an unauthenticated user
    Given I visit the About page
    Then I should see About page content

  Scenario: Visit the About page as an authenticated user
    Given I am logged in as any user
    And I visit the About page
    Then I should see About page content
